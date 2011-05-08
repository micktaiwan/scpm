require 'builder'

class ProjectsController < ApplicationController

  before_filter :require_login

  def index
    get_projects
    @last_update = Request.find(:first, :select=>"updated_at", :order=>"updated_at desc" ).updated_at
    case session[:project_sort]
      when nil
        @projects = @projects.sort_by { |p| d = p.last_status_date; [p.project_requests_progress_status_html == 'ended' ? 1 : 0, d ? d : Time.zone.now] }
        @wps = @wps.sort_by { |p| p.read_date ? p.read_date : Time.now-1.year}
      when 'alpha'
        @projects = @projects.sort_by { |p| [p.workstream, p.name] }
        @wps = @wps.sort_by { |p| p.full_name }
    end
    @supervisors  = Person.find(:all, :conditions=>"is_supervisor=1", :order=>"name asc")
    @qr           = Person.find(:all, :conditions=>"is_supervisor=0 and has_left=0", :order=>"name asc")
    @workstreams  = Project.all.collect{|p| p.workstream}.uniq.sort
    @actions      = Action.find(:all, :conditions=>["progress in('in_progress', 'open') and person_id in (?)", session[:project_filter_qr]])
    if @wps.size > 0
      @amendments   = Amendment.find(:all, :conditions=>"done=0 and project_id in (#{@wps.collect{|p| p.id}.join(',')})", :order=>"duedate")
    else
      @amendments   = []
    end
  end

  def new
    @project = Project.new(:project_id=>nil, :name=>'')
    @supervisors  = Person.find(:all, :conditions=>"is_supervisor=1", :order=>"name asc")
  end

  def create
    @project = Project.new(params[:project])
    if not @project.save
      render :action => 'new'
      return
    end
    redirect_to("/projects")
  end

  def upload
  end

  def filter
    pws = params[:ws]
    if not pws; session[:project_filter_workstream] = nil
    else;       session[:project_filter_workstream] = "(#{pws.map{|t| "'#{t}'"}.join(',')})"
    end
    pst = params[:st]
    if not pst; session[:project_filter_status] = nil
    else;       session[:project_filter_status] = "(#{pst.map{|t| "'#{t}'"}.join(',')})"
    end
    sup = params[:sup]
    if not sup; session[:project_filter_supervisor] = nil
    else;       session[:project_filter_supervisor] = "(#{sup.map{|t| "'#{t}'"}.join(',')})"
    end
    qr = params[:qr]
    if not qr;  session[:project_filter_qr] = nil
    else;       session[:project_filter_qr] = qr.map {|t| t.to_i}
    end
    session[:project_filter_text] = params[:text]
    redirect_to(:action=>'index')
  end

  def show
    id = params['id']
    @project = Project.find(id)
    @project.create_milestones
    @status = @project.get_status
    @old_statuses = @project.statuses - [@status]
  end

  def edit
    id = params[:id]
    @project = Project.find(id)
    @supervisors = Person.find(:all, :conditions=>"is_supervisor=1", :order=>"name asc")
  end

  def edit_status
    id = params['id']
    @status = Status.find(id)
    @project = @status.project
  end

  def update
    project = Project.find(params[:id])
    project.update_attributes(params[:project])
    project.propagate_attributes
    redirect_to :action=>:show, :id=>project.id
  end

  def update_status
    timestamps_off if params[:update] != '1'
    status = Status.find(params[:id])
    status.update_attributes(params[:status])
    status.last_modifier = current_user.id
    status.save
    p = status.project
    p.update_status(params[:status][:status]) if p.get_status.id == status.id # only if we are updating the last status
    p.calculate_diffs
    Mailer::deliver_status_change(p)
    timestamps_on if params[:update] != '1'
    redirect_to :action=>:show, :id=>status.project_id
  end

  # check request and suggest projects
  def import
    @import = []
    Request.find(:all, :conditions=>"project_id is null", :order=>"workstream").each { |r|
      @import << {:id=>r.id, :project_name=>r.project_name, :summary=>r.summary, :workstream=>r.workstream}
      }
  end

  # for each request rename project if necessary
  # find projects with nothing in it
  def check
    @text = ""
    timestamps_off
    Request.find(:all, :conditions=>"project_id is not null").each do |r|
      if r.workpackage_name != r.project.name
        projects = Project.find(:all, :conditions=>"name='#{r.workpackage_name}'")
        @text << "found #{projects.size} projects with name '#{r.workpackage_name}' (#{r.project_name})"
        projects.each { |p|
          @text << ", wp belongs to #{p.project ? p.project.name : 'no parent'}"
          projects.delete(p) if not p.project or p.project.name != r.project_name
          }
        @text << " => #{projects.size} projects has the right parent<br/>"
        #next
        if projects.size == 0
          parent = Project.find(:first, :conditions=>"name='#{r.project_name}'")
          if not parent
            # create parent
            parent_id = Project.create(:project_id=>nil, :name=>r.project_name, :workstream=>r.workstream).id
          else
            parent_id = parent.id
          end
          #create wp
          p = Project.create(:project_id=>parent_id, :name=>r.workpackage_name, :workstream=>r.workstream)
          if r.project.requests.size == 1 # if that was the only request move all statuts and actions, etc.. to new project
            @text << "<u>#{r.project.full_name}</u>: #{r.workpackage_name} (new) != #{r.project.name} (old) => creating and moving ALL<br/>"
            r.project.move_all(p)
          else
            @text << "<u>#{r.project.full_name}</u>: #{r.workpackage_name} (new) != #{r.project.name} (old) => creating and moving only request (not status and actions, etc...)<br/>"
          end
          r.move_to_project(p)
        else
          if r.project.requests.size == 1 # if that was the only request move all statuts and actions, etc.. to new project
            @text << "<u>#{r.project.full_name}</u>: #{r.workpackage_name} (new) != #{r.project.name} (old) => moving ALL<br/>"
            r.project.move_all(projects[0])
          else
            @text << "<u>#{r.project.full_name}</u>: #{r.workpackage_name} (new) != #{r.project.name} (old) => moving only request (not status and actions, etc...)<br/>"
          end
          r.move_to_project(projects[0])
        end
      end
      if (r.project and r.project.project and r.project.project.name != r.project_name)
        @text << "FYI #{r.project.project.name} != #{r.project_name} (#{r.request_id})<br/>"
      end
      if (r.milestone != 'N/A' and (r.work_package[0..2]=="WP2" or r.work_package[0..2]=="WP3" or r.work_package[0..2]=="WP4" or r.work_package[0..2]=="WP5" or r.work_package[0..2]=="WP6"))
        @text << "not N/A for <a href='http://toulouse.sqli.com/EMN/view.php?id=#{r.request_id}'>#{r.project_name}</a><br/>"
      end
    end
    Project.find(:all, :conditions=>"supervisor_id is null and project_id is not null").each { |p|
      p.supervisor_id = p.project.supervisor_id
      p.save
      }
    @projects         = Project.find(:all).select{ |p| p.projects.size == 0 and p.requests.size == 0}
    @root_requests    = Project.find(:all, :conditions=>"project_id is null").select{ |p| p.requests.size > 0}
    @display_actions  = true
    @missing_associations = find_missing_project_person_associations
    timestamps_on
  end

  def check_sdp
    i = ImportSDP.new
    i.open('C:\Users\faivremacon\My Documents\Downloads\Rapport.xls')
    list = i.list
    i.close
    all_requests = Request.find(:all).collect {|r| r.request_id.to_i}
    no_requests  = Request.find(:all, :conditions=>"sdp!='No' and status!='cancelled'").collect {|r| r.request_id.to_i}
    @in_sdp = (list - all_requests).sort
    @in_rmt = (all_requests - list).sort
    @no_in_rmt_but_in_sdp = (list - no_requests).sort
    #render(:text=>@list.size)
  end

  def add_status_form
    @project = Project.find(params[:id])
    @status = Status.new
    last = @project.get_status
    @status.explanation       = last.explanation
    @status.feedback          = last.feedback
    @status.reason            = last.reason
    @status.status            = last.status
    @status.last_change       = last.last_change
    @status.actions           = last.actions
    @status.ereporting_date   = last.ereporting_date
    @status.operational_alert = last.operational_alert
  end

  def add_status
    project_id  = params[:status][:project_id]
    status      = Status.create(params[:status])
    status.last_modifier = current_user.id
    status.save
    p           = Project.find(project_id)
    p.update_status(params[:status][:status])
    p.calculate_diffs
    Mailer::deliver_status_change(p)
    redirect_to :action=>:show, :id=>project_id
  end

  # link a request to a project, based on request project_name
  # if the project does not exists, create it
  def link
    request_id        = params[:id]
    request           = Request.find(request_id)
    project_name      = request.project_name
    workpackage_name  = request.workpackage_name
    brn               = request.brn

    project = Project.find_by_name(project_name)
    if not project
      project = Project.create(:name=>project_name)
      project.workstream = request.workstream
      project.save
    end

    wp = Project.find_by_name(workpackage_name, :conditions=>["project_id=?",project.id])
    if not wp
      wp = Project.create(:name=>workpackage_name)
      wp.workstream = request.workstream
      wp.brn        = brn
      wp.project_id = project.id
      wp.save
    end

    request.project_id = wp.id
    request.save
    project.add_responsible_from_rmt_user(request.assigned_to) if request.assigned_to != ""
    render(:text=>"saved")
  end

  def associate
    request = Request.find(params[:id].to_i)
    #puts request.id
    if request.project.add_responsible_from_rmt_user(request.assigned_to)
      render(:text=>"")
    else
      render(:text=>"Error. Is the rmt_user declared for this user ?")
    end
  end

  def add_to_mine
    Project.find(params[:id]).add_responsible(current_user)
    render(:nothing=>true)
  end

  def remove_from_mine
    Project.find(params[:id]).responsibles.delete(current_user)
    render(:nothing=>true)
  end

  def mark_as_read
    p           = Project.find(params[:id])
    p.read_date = Time.now
    p.save
    render(:nothing=>true)
  end


  def cut
    session[:cut]         = params[:id]
    session[:action_cut]  = nil
    session[:status_cut]  = nil
    session[:request_cut] = nil
    render(:nothing => true)
  end

  def cut_status
    session[:status_cut]  = params[:id]
    session[:action_cut]  = nil
    session[:cut]         = nil
    session[:request_cut] = nil
    render(:nothing => true)
  end

  def paste
    timestamps_off
    paste_project if session[:cut]          != nil
    paste_action  if session[:action_cut]   != nil
    paste_request if session[:request_cut]  != nil
    paste_status  if session[:status_cut]   != nil
    timestamps_on
  end

  def paste_project
    to_id   = params[:id].to_i
    cut_id  = session[:cut].to_i
    cut     = Project.find(cut_id)
    from_id = cut.project_id
    cut.project_id = to_id
    cut.save
    cut.update_status
    Project.find(from_id).update_status if from_id
    render(:nothing=>true)
  end

  def paste_action
    to_id   = params[:id].to_i
    cut_id  = session[:action_cut].to_i
    cut     = Action.find(cut_id)
    from_id = cut.project_id
    cut.project_id = to_id
    cut.save
    render(:nothing=>true)
  end

  def paste_request
    to_id   = params[:id].to_i
    cut_id  = session[:request_cut].to_i
    cut     = Request.find(cut_id)
    from_id = cut.project_id
    cut.project_id = to_id
    cut.save
    render(:nothing=>true)
  end

  def paste_status
    to_id   = params[:id].to_i
    cut_id  = session[:status_cut].to_i
    cut     = Status.find(cut_id)
    from_id = cut.project_id
    cut.project_id = to_id
    cut.save
    Project.find(to_id).update_status
    Project.find(from_id).update_status
    render(:nothing=>true)
  end

  def destroy
    p = Project.find(params[:id].to_i)
    if(p.projects.size > 0 or p.has_status or p.has_requests or p.amendments.size > 0 or p.actions.size > 0 or p.notes.size > 0)
      render(:status=>500, :text=>"#{p.full_name} is not empty")
      return
    end
    p.destroy
    render(:nothing=>true)
  end

  def destroy_status
    Status.find(params[:id].to_i).destroy
    render(:nothing=>true)
  end

  def report
    get_projects
    @projects     = @projects.sort_by { |p| [p.supervisor_name, p.workstream, p.name] }
    @supervisors  = Person.find(:all, :conditions=>"is_supervisor=1", :select=>"id, name",:order=>"name")
    #@wps         = @wps.sort_by { |p| [p.workstream, p.full_name] }
    @size         = @projects.size
    @report       = Report.new(Request.all)
    @topics       = Topic.find(:all, :conditions=>"(done=0 or (done=1 and done_date >= '#{Date.today-18.days}')) and private=0", :order=>"done, person_id, id desc")
    render(:layout=>'report')
  end

  # generate an Excel file to summarize projects status
  def summary
    #render(:text=>"filter on text on => no summary is possible") and return if not @wps
    begin
      @xml = Builder::XmlMarkup.new(:indent => 1) #Builder::XmlMarkup.new(:target => $stdout, :indent => 1)
      get_projects
      @wps = @wps.sort_by { |w|
        [w.supervisor_name, w.workstream, w.project_name, w.name]
        }
      @actions    = Action.find(:all, :conditions=>"private=0", :order=>"person_id, creation_date, progress")
      @requests   = Request.find(:all,:conditions=>"status!='assigned' and status!='cancelled' and status!='closed' and status!='removed'", :order=>"status, workstream")
      @topics     = Topic.find(:all,  :conditions=>"private=0", :order=>"done, person_id, id desc")
      if @wps.size > 0
        @amendments   = Amendment.find(:all, :conditions=>"project_id in (#{@wps.collect{|p| p.id}.join(',')})", :order=>"duedate")
      else
        @amendments   = []
      end

      @status_progress_series = get_status_progress
      @status_columns         = ['Centre','Status']
      @status_progress_dates  = []
      @status_progress_series['Total'].keys.sort.each { |date|
        @status_columns << date
        @status_progress_dates << date
        }
      date = "2011-03-15"
      wps          = Request.find(:all, :conditions=>["total_csv_category >= ?", date], :order=>"workstream, project_id, total_csv_category")
      wps.each { |r| r.reporter = "WP change" }
      complexities = Request.find(:all, :conditions=>["total_csv_severity >= ?", date], :order=>"workstream, project_id, total_csv_severity")
      complexities.each { |r| r.reporter = "Complexity change" }
      news         = Request.find(:all, :conditions=>["status_new >= ?", date], :order=>"workstream, project_id, status_new")
      news.each { |r| r.reporter = "New" }
      performed    = Request.find(:all, :conditions=>["status_performed >= ?", date], :order=>"workstream, project_id, status_performed")
      performed.each { |r| r.reporter = "Performed" }
      closed       = Request.find(:all, :conditions=>["status_closed >= ?", date], :order=>"workstream, project_id, status_closed")
      closed.each { |r| r.reporter = "Closed" }
      @changes = wps + complexities + news + performed + closed

      date = Date.today-((Date.today().wday+6).days)

      wps          = Request.find(:all, :conditions=>["total_csv_category >= ?", date], :order=>"workstream, project_id, total_csv_category")
      wps.each { |r| r.reporter = "WP change" }
      complexities = Request.find(:all, :conditions=>["total_csv_severity >= ?", date], :order=>"workstream, project_id, total_csv_severity")
      complexities.each { |r| r.reporter = "Complexity change" }
      news         = Request.find(:all, :conditions=>["status_new >= ?", date], :order=>"workstream, project_id, status_new")
      news.each { |r| r.reporter = "New" }
      performed    = Request.find(:all, :conditions=>["status_performed >= ?", date], :order=>"workstream, project_id, status_performed")
      performed.each { |r| r.reporter = "Performed" }
      closed       = Request.find(:all, :conditions=>["status_closed >= ?", date], :order=>"workstream, project_id, status_closed")
      closed.each { |r| r.reporter = "Closed" }
      @week_changes = wps + complexities + news + performed + closed

      headers['Content-Type']         = "application/vnd.ms-excel"
      headers['Content-Disposition']  = 'attachment; filename="Summary.xls"'
      headers['Cache-Control']        = ''
      render(:layout=>false)
    rescue Exception => e
      render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
    end
  end

  def week_changes
    #date = Date.today()-7.days
    date = "2011-03-15"
    @wps          = Request.find(:all, :conditions=>["total_csv_category >= ?", date], :order=>"workstream, project_id, total_csv_category")
    @complexities = Request.find(:all, :conditions=>["total_csv_severity >= ?", date], :order=>"workstream, project_id, total_csv_severity")
    @news         = Request.find(:all, :conditions=>["status_new >= ?", date], :order=>"workstream, project_id, status_new")
    @performed    = Request.find(:all, :conditions=>["status_performed >= ?", date], :order=>"workstream, project_id, status_performed")
    @closed       = Request.find(:all, :conditions=>["status_closed >= ?", date], :order=>"workstream, project_id, status_closed")
  end

private

  def get_status_progress
    date = Hash.new
    for center in ['Total', 'EA', 'EI', 'EV', 'EDE', 'EDG', 'EDS', 'EDY', 'EDC', 'EM', 'EMNB', 'EMNC']
      date[center] = Hash.new
      month_loop(5,2010) { |to|
        date[center][to] = Array.new
        Project.find(:all).each { |p|
          next if not p.open_requests.size > 0 or not p.has_status or (center != 'Total' and p.workstream != center)
          last_status = p.get_status(to)
          date[center][to] << last_status
          }
        }
    end
    date
  end

  def timestamps_off
    Project.record_timestamps = false
    Status.record_timestamps  = false
    Action.record_timestamps  = false
    Request.record_timestamps = false
  end

  def timestamps_on
    Project.record_timestamps = true
    Status.record_timestamps  = true
    Action.record_timestamps  = true
    Request.record_timestamps = true
  end

  def get_projects
    if session[:project_filter_text] != "" and session[:project_filter_text] != nil
      @projects = Project.all.select {|p| p.text_filter(session[:project_filter_text]) }
      @wps = @projects.select {|wp| wp.has_status and wp.has_requests }
      return
    end
    cond = []
    cond << "workstream in #{session[:project_filter_workstream]}" if session[:project_filter_workstream] != nil
    cond << "last_status in #{session[:project_filter_status]}" if session[:project_filter_status] != nil
    cond << "supervisor_id in #{session[:project_filter_supervisor]}" if session[:project_filter_supervisor] != nil
    @wps = Project.find(:all, :conditions=>cond.join(" and "), :include=>['projects', 'requests', 'actions']) # do not filter workpackages with project is null
    @wps = @wps.select {|wp| wp.open_requests.size > 0 } # wp.has_status
    cond << "project_id is null"
    @projects = Project.find(:all, :conditions=>cond.join(" and "))
    if session[:project_filter_qr] != nil
      @projects = @projects.select {|p| p.has_responsible(session[:project_filter_qr]) }
      @wps = @wps.select {|p| p.has_responsible(session[:project_filter_qr]) }
    end
  end

  def no_responsible(p)
    p.active_requests.map { |r| r.assigned_to }.uniq.each { |name|
      next if name == ""
      return true if not p.responsibles.include?(Person.find_by_rmt_user(name))
      }
    return false
  end

  def find_missing_project_person_associations
    Project.all.select { |p|
      no_responsible(p)
      }
  end

end

