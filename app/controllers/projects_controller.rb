class ProjectsController < ApplicationController

  def index
    @projects = Project.find(:all, :conditions=>"project_id is null", :order=>'workstream')
  end
  
  def show
    id = params['id']
    @project = Project.find(id)
  end

  # check request and suggest projects
  def import
    @import = []
    Request.find(:all, :conditions=>"project_id is null").each { |r|
      @import << {:id=>r.id, :project_name=>r.project_name, :summary=>r.summary}
      }
  end
  
  # link a request to a project, based on request project_name
  # if the project does not exists, create it
  def link
    request_id    = params[:id]
    request = Request.find(request_id)
    project_name  = request.project_name
    workpackage_name = request.summary.split(/\[([^\]]*)\]/)[3]
    workpackage_name = project_name if workpackage_name == nil or workpackage_name == ""
    brn = request.summary.split(/\[([^\]]*)\]/)[5]

    project = Project.find_by_name(project_name)
    if not project
      project = Project.create(:name=>project_name)
      project.workstream = request.workstream
      project.save
    end

    wp = Project.find_by_name(workpackage_name)
    if not wp
      wp = Project.create(:name=>workpackage_name)
      wp.workstream = request.workstream
      wp.brn = brn
      wp.project_id = project.id
      wp.save
    end

    request.project_id = wp.id
    request.save
    render(:text=>"saved")
  end

end

