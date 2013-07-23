class ProjectWorkloadsController < ApplicationController
	layout 'pdc'

  before_filter :require_login
  before_filter :require_admin


  def index
    project_id = params[:project_id]
    session['workload_project_id'] = project_id if project_id
    @projects = Project.find(:all, :conditions=>"project_id is null", :order=>"name")
    if @projects.size > 0
      session['workload_project_id'] = @projects.first.id if not session['workload_project_id'] or not Project.find_by_id(session['workload_project_id'])
    else
      render(:text=>'no project at all... Please create a new project.')
      return
    end
    get_common_data(session['workload_project_id'])
    @projects = @projects.map {|p| ["#{p.name} (#{p.wl_lines.size})", p.id]}
    change_workload(session['workload_project_id'])
     # respond_to do |format|
     #   format.csv { render :csv => @projects}
     # end
  end


  def xml_export
    begin
      @xml = Builder::XmlMarkup.new(:indent => 1)

      @workload = ProjectWorkload.new(session['workload_project_id'], {:hide_lines_with_no_workload => session['workload_hide_lines_with_no_workload'].to_s=='true', :group_by_person => session['group_by_person'].to_s=='true'})
      
      # MONTHS EXPORT
      @months = ["", "", "", "","",""]
      for i in @workload.months
        @months << i
      end
      
      # WEEKS EXPORT
      @weeks = ["","","","","",""]
      for i in @workload.weeks
        @weeks << i
      end

      # DAYS EXPORT
      @days = ["","Init.","Gain","Rem.","Planned","Total"]
      for i in @workload.days
        @days << i
      end

      # OPENS EXPORT
      @opens = ["Nb of worked days","","","","",""]
      for i in @workload.opens
        @opens << i
      end

      # CTOTALS EXPORT
      @ctotals = ["Total","","","","",""]
      for i in @workload.ctotals
        @ctotals << i[:value]
      end

      # SUMS / PERCENTS EXPORT
      @sums_percents = ["Sums / Percents","",""] << @workload.sdp_remaining_total
      @sums_percents << @workload.planned_total
      @sums_percents << @workload.total
      for i in @workload.percents
        @sums_percents << i[:value]
      end

      # AVAILABILITY EXPORT
      @availability = ["Availability (Sum for the 2 next months)","","",""] << @workload.sum_availability
      @availability << ""
      for i in @workload.availability
        @availability << i[:value]
      end

      # WORKLOADS EXPORT
      @lines =[]
      for l in @workload.wl_lines
        line = []
        line << l.person.name
        line << @workload.line_sums[l.id][:init]
        line << @workload.line_sums[l.id][:balance]
        line << @workload.line_sums[l.id][:remaining]
        line << @workload.line_sums[l.id][:sums]
        line << l.sum
        for week in @workload.wl_weeks
          workload = ""
          for wl in l.wl_loads
             if (wl.week == week) #and (wl.wl_line_id == l.id) A revoir
              workload = wl.wlload
             end
          end
          line << workload
        end
         @lines << line
      end

      headers['Content-Type']         = "application/vnd.ms-excel"
      headers['Content-Disposition']  = 'attachment; filename="porject_workload.xls"'
      headers['Cache-Control']        = ''
      render(:layout=>false)
    end
  end

  
  def change_workload(project_id=nil)
    project_id  = params[:project_id] if !project_id
    session['workload_project_id'] = project_id
    get_common_data(project_id)
  end

  def add_a_person
    person_id     = params[:person_id]
    project_id    = params[:project_id]
    found         = WlLine.find_by_person_id_and_project_id(person_id, project_id)
    person_name   = Person.find(person_id).name
    project_name  = Project.find(project_id).name
    if not found
      @line = WlLine.create(:name=>project_name , :project_id=>project_id, :request_id=>nil, :person_id=>person_id, :wl_type=>WL_LINE_OTHER)
      get_common_data(project_id)
    else
      @error = "This line already exists: #{person_name}"
    end
  end

  def hide_lines_with_no_workload
    on = (params[:on].to_s != 'false')
    session['workload_hide_lines_with_no_workload'] = on
    get_common_data(session['workload_project_id'])
  end

  def group_by_person
    on = (params[:on].to_s != 'false')
    session['group_by_person'] = on
    get_common_data(session['workload_project_id'])
  end

private

  def get_common_data(project_id)
    @people   = Person.find(:all, :conditions=>"has_left=0", :order=>"name").map {|p| ["#{p.name}", p.id]}
    @workload = ProjectWorkload.new(project_id, {:hide_lines_with_no_workload => session['workload_hide_lines_with_no_workload'].to_s=='true', :group_by_person => session['group_by_person'].to_s=='true'})
  end

  def require_admin
    if !current_user.has_role?('Admin') and !current_user.has_role?('ServiceLineResp')
      render(:text=>"You're not allowed to view this page. This is sad.")
      return
    end
  end

end
