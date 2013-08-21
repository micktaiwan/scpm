class ProjectWorkloadsController < ApplicationController
	layout 'pdc'

  before_filter :require_login
  before_filter :require_admin


  def index
    project_ids = params[:project_ids]
    if project_ids
      if project_ids.class==Array
        session['workload_project_ids'] = project_ids # array of strings
      else
        session['workload_project_ids'] = [project_ids] # array with one string
      end
    else
      if session['workload_project_ids'] == nil
        session['workload_project_ids'] = []
      end
    end
    #raise "#{session['workload_project_ids'].map{ |id| id}.join(', ')}"

    @projects = Project.find(:all, :conditions=>"project_id is null", :order=>"name")
    if not session['workload_project_ids'] or session['workload_project_ids']==[]
      return
    end

    if @projects.size > 0
      session['workload_project_ids'] = [@projects.first.id] if not session['workload_project_ids']
      # or not Project.find_by_id(session['workload_project_ids'])
    else
      render(:text=>'no project at all... Please create a new project.')
      return
    end
    @project_options = @projects.map {|p| ["#{p.name} (#{p.wl_lines.size})", p.id]}
    get_common_data(session['workload_project_ids'])
    get_last_sdp_update
  end

  def xml_export
    begin
      @xml = Builder::XmlMarkup.new(:indent => 1)

      @workload = ProjectWorkload.new(session['workload_project_ids'], {:hide_lines_with_no_workload => session['workload_hide_lines_with_no_workload'].to_s=='true', :group_by_person => session['group_by_person'].to_s=='true'})
      
      # MONTHS EXPORT
      @months = ["#{@workload.names}","","", "", "", "","",""]
      for i in @workload.months
        @months << i
      end
      
      # WEEKS EXPORT
      @weeks = ["","","","","","","",""]
      for i in @workload.weeks
        @weeks << i
      end

      # DAYS EXPORT
      @days = ["","","","Init.","Gain","Rem.","Planned","Total"]
      for i in @workload.days
        @days << i
      end

      # OPENS EXPORT
      @opens = ["","Nb of worked days","","","","","",""]
      for i in @workload.opens
        @opens << i
      end

      # CTOTALS EXPORT
      @ctotals = ["","Total","","","","","",""]
      for i in @workload.ctotals
        @ctotals << i[:value]
      end

      # SUMS / PERCENTS EXPORT
      @sums_percents = ["","Sums / Percents","","",""] << @workload.sdp_remaining_total
      @sums_percents << @workload.planned_total
      @sums_percents << @workload.total
      for i in @workload.percents
        @sums_percents << i[:value]
      end

      # AVAILABILITY EXPORT
      @availability = ["","Availability (Sum for the 2 next months)","","","",""] << @workload.sum_availability
      @availability << ""
      for i in @workload.availability
        @availability << i[:value]
      end

      # WORKLOADS EXPORT
      @lines =[]
      @virtual= Hash.new
      @line_countable = Hash.new
      line_pos = 0
      for l in @workload.wl_lines
        line_pos += 1
        if l.person and l.person.is_virtual == 1
          @virtual[line_pos] = true
        else
          @virtual[line_pos] = false
        end
        if l.wl_type <= 200 or l.wl_type == 500
          @line_countable[line_pos] = true
        else
          @line_countable[line_pos] = false
        end
        line = []
        line << l.person.company.name
        line << l.person.name
        line << l.name
        line << @workload.line_sums[l.id][:init]
        line << @workload.line_sums[l.id][:balance]
        line << @workload.line_sums[l.id][:remaining]
        line << @workload.line_sums[l.id][:sums]
        line << l.sum
        for week in @workload.wl_weeks
          workload = l.get_load_by_week(week)
          line << workload
        end
         @lines << line
      end
      #raise "#{@line_countable.collect { |t| t }}"
      headers['Content-Type']         = "application/vnd.ms-excel"
      headers['Content-Disposition']  = 'attachment; filename="project_workload.xls"'
      headers['Cache-Control']        = ''
      render(:layout=>false)
    end
  end

  def change_workload(project_ids=nil)
    project_ids = params[:project_ids]
    if project_ids
      session['workload_project_ids'] = project_ids
    else
      session['workload_project_ids'] = []
    end

    @projects = Project.find(:all, :conditions=>"project_id is null", :order=>"name")
    if not session['workload_project_ids'] or session['workload_project_ids']==[]
      return
    end

    if @projects.size > 0
      session['workload_project_ids'] = [@projects.first.id] if not session['workload_project_ids']
      # or not Project.find_by_id(session['workload_project_ids'])
    else
      render(:text=>'no project at all... Please create a new project.')
      return
    end
    @project_options = @projects.map {|p| ["#{p.name} (#{p.wl_lines.size})", p.id]}
    get_common_data(session['workload_project_ids'])
  end

  def add_a_person
    person_id     = params[:person_id]
    project_id    = params[:project_ids]
    found         = WlLine.find_by_person_id_and_project_id(person_id, project_ids.first)
    person_name   = Person.find(person_id).name
    project_name  = Project.find(project_ids.first).name
    if not found
      @line = WlLine.create(:name=>project_name , :project_id=>project_ids.first, :request_id=>nil, :person_id=>person_id, :wl_type=>WL_LINE_OTHER)
      get_common_data(project_ids)
    else
      @error = "This line already exists: #{person_name}"
    end
  end

  def hide_lines_with_no_workload
    on = (params[:on].to_s != 'false')
    session['workload_hide_lines_with_no_workload'] = on
    get_common_data(session['workload_project_ids'])
  end

  def group_by_person
    on = (params[:on].to_s != 'false')
    session['group_by_person'] = on
    get_common_data(session['workload_project_ids'])
  end

private

  def get_common_data(project_ids)
    @people   = Person.find(:all, :conditions=>"has_left=0", :order=>"name").map {|p| ["#{p.name}", p.id]}
    @workload = ProjectWorkload.new(project_ids, {:hide_lines_with_no_workload => session['workload_hide_lines_with_no_workload'].to_s=='true', :group_by_person => session['group_by_person'].to_s=='true'})
  end

  def get_last_sdp_update
    @last_sdp_phase = SDPPhase.find(:first, :order=>'updated_at desc')
    if @last_sdp_phase != nil
      @last_sdp_update = @last_sdp_phase.updated_at
    else
      @last_sdp_update = nil
    end
  end

  def require_admin
    if !current_user.has_role?('Admin') and !current_user.has_role?('ServiceLineResp')
      render(:text=>"You're not allowed to view this page. This is sad.")
      return
    end
  end

end
