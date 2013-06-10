class ProjectWorkloadsController < ApplicationController
	layout 'pdc'

  before_filter :require_login
  before_filter :require_admin

  def index
    @projects = Project.find(:all, :conditions=>"project_id is null", :order=>"name")
    if @projects.size > 0
      session['workload_project_id'] = @projects.first.id if not session['workload_project_id']
    else
      render(:text=>'no project at all...')
      return
    end
    get_common_data(session['workload_project_id'])
    @projects = @projects.map {|p| ["#{p.name} (#{p.wl_lines.size})", p.id]}
    change_workload(session['workload_project_id'])
  end

  def change_workload(project_id=nil)
    project_id  = params[:project_id] if !project_id
    session['workload_project_id'] = project_id
    get_common_data(project_id)
    #get_last_sdp_update
    #get_suggested_requests(@workload)
    #get_sdp_tasks(@workload)
    #get_chart
    #get_sdp_gain(@workload.person)
  end

  def add_a_person
    person_id   = params[:person_id]
    project_id  = params[:project_id]
    found       = WlLine.find_by_person_id_and_project_id(person_id, project_id)
    person_name   = Person.find(person_id).name
    project_name  = Project.find(project_id).name
    if not found
      @line = WlLine.create(:name=>project_name , :project_id=>project_id, :request_id=>nil, :person_id=>person_id, :wl_type=>WL_LINE_OTHER)
      get_common_data(project_id)
      #get_last_sdp_update
      #get_suggested_requests(@workload)
      #get_sdp_gain(@workload.person)
      #get_chart
      #get_sdp_gain(@workload.person)
    else
      @error = "This line already exists: #{person_name}"
    end
  end

private

  def get_common_data(project_id)
    @people   = Person.find(:all, :conditions=>"has_left=0", :order=>"name").map {|p| ["#{p.name}", p.id]}
    @workload = ProjectWorkload.new(project_id, {:hide_lines_with_no_workload => session['workload_hide_lines_with_no_workload'].to_s=='true'})
    puts @workload.project_id
  end

  def require_admin
    if !current_user.has_role?('Admin') and !current_user.has_role?('ServiceLineResp')
      render(:text=>"You're not allowed to view this page. This is sad.")
      return
    end
  end

end
