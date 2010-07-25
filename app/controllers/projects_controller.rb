class ProjectsController < ApplicationController

  def index
    @projects = Project.find(:all, :conditions=>"project_id is null", :order=>'workstream, name')
  end
  
  def show
    id = params['id']
    @project = Project.find(id)
    @status = @project.get_status
  end

  def edit
    id = params['id']
    @project = Project.find(id)
  end
  
  def update
    project = Project.find(params[:id])
    project.update_attributes(params[:project])
    redirect_to :action=>:show, :id=>project.id
  end
  
  # check request and suggest projects
  def import
    @import = []
    Request.find(:all, :conditions=>"project_id is null", :order=>"workstream").each { |r|
      @import << {:id=>r.id, :project_name=>r.project_name, :summary=>r.summary, :workstream=>r.workstream}
      }
  end
  
  # for each request rename project if necessary
  def check
    t = ""
    Request.find(:all, :conditions=>"project_id is not null").each { |r|
      if r.workpackage_name != r.project.name
        t << "#{r.workpackage_name} != #{r.project.name}<br/>" 
        project = Project.find_by_name(r.workpackage_name)
        if not project
          r.project.name = r.workpackage_name
          r.project.save
        else
          r.project_id = project.id
          r.save  
        end        
      end    
      }
    t << "<br/><a href='/projects'>back to projects</a>"
    render(:text=>t)  
  end
  
  def add_status_form
    @project = Project.find(params[:project_id])
    @status = Status.new
  end
  
  def add_status
    project_id = params[:status][:project_id]
    status = Status.create(params[:status])
    p = Project.find(project_id)
    p.last_status = params[:status][:status]
    p.save
    p.project.update_status if p.project
    redirect_to :action=>:show, :id=>project_id
  end
  
  # link a request to a project, based on request project_name
  # if the project does not exists, create it
  def link
    request_id    = params[:id]
    request = Request.find(request_id)
    project_name  = request.project_name
    workpackage_name = request.workpackage_name
    brn = request.brn

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
      wp.brn = brn
      wp.project_id = project.id
      wp.save
    end

    request.project_id = wp.id
    request.save
    render(:text=>"saved")
  end
  
  def cut
    session[:cut] = params[:id]
    render(:nothing=>true)
  end

  def paste
    to_id   = params[:id].to_i
    from_id = session[:cut].to_i
    from = Project.find(from_id)
    from.project_id = to_id
    from.save
    render(:nothing=>true)
  end

end

