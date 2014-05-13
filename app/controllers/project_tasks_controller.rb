# project workload but with a simplier view
class ProjectTasksController < ApplicationController
  layout 'pdc'

  before_filter :require_login
  before_filter :require_admin
  
  def index
    project_ids    = params[:project_ids]
    companies_ids  = params[:companies_ids]
    iterations_ids = params[:iterations_ids]
    tags_ids       = params[:tags_ids]
    if project_ids
      if project_ids.class==Array
        session['workload_project_ids'] = project_ids # array of strings
      else
        session['workload_project_ids'] = [project_ids] # array with one string
      end
    else
      if session['workload_project_ids'] == nil or session['workload_project_ids'] == ''
        session['workload_project_ids'] = []
      end
    end
    if companies_ids
      if companies_ids.class==Array
        session['workload_companies_ids'] = companies_ids # array of strings
      else
        session['workload_companies_ids'] = [companies_ids] # array with one string
      end
    else
      if session['workload_companies_ids'] == nil or session['workload_companies_ids'] == ''
        session['workload_companies_ids'] = []
      end
    end
    session['workload_iterations'] = []
    if iterations_ids
      iterations_ids.each do |i|
        iteration       = Iteration.find(i)
        iteration_name  = iteration.name
        project_code    = iteration.project_code
        project_id      = iteration.project.id
        session['workload_iterations'] << {:name=>iteration_name, :project_code=>project_code, :project_id=>project_id}
      end
    end
    session['workload_tags'] = []
    if tags_ids
      if tags_ids.class==Array
        session['workload_tags'] = tags_ids # array of strings
      else
        session['workload_tags'] = [tags_ids] # array with one string
      end
    end
    @projects = Project.find(:all, :conditions=>"project_id is null", :order=>"name")
    return if not session['workload_project_ids'] or session['workload_project_ids']==[]

    if @projects.size > 0
      session['workload_project_ids'] = [@projects.first.id] if not session['workload_project_ids']
    else
      render(:text=>'no project at all... Please create a new project.')
      return
    end
    @project_options = @projects.map {|p| ["#{p.name} (#{p.wl_lines.size})", p.id]}
    get_common_data(session['workload_project_ids'],session['workload_companies_ids'],session['workload_iterations'],session['workload_tags'])
  end

  def hide_lines_with_no_workload
    on = (params[:on].to_s != 'false')
    session['workload_hide_lines_with_no_workload'] = on
    get_common_data(session['workload_project_ids'],session['workload_companies_ids'],session['workload_iterations'],session['workload_tags'])
  end

  def group_by_person
    on = (params[:on].to_s != 'false')
    session['group_by_person'] = on
    get_common_data(session['workload_project_ids'],session['workload_companies_ids'],session['workload_iterations'],session['workload_tags'])
  end

private

  def get_common_data(project_ids, companies_ids, iterations, tags_ids)
    @people   = Person.find(:all, :conditions=>"has_left=0", :order=>"name").map {|p| ["#{p.name}", p.id]}
    @workload = ProjectWorkload.new(project_ids, companies_ids, iterations,tags_ids, {:hide_lines_with_no_workload => session['workload_hide_lines_with_no_workload'].to_s=='true', :group_by_person => session['group_by_person'].to_s=='true'})
    total = 0
    @workload.wl_lines.each {|l|
      if l.person.cost_profile
        s = l.person.cost_profile.cost * l.sum
        l[:cost_total] = s.to_i
        total += s
      else
        l[:cost_total] = 0
      end
    }
    @cost_total = total.to_i
    @total_sales_revenue = @workload.projects.inject(0){|sum, i| sum += i.sales_revenue}
    if @total_sales_revenue > 0
      @margin = (1 - (@cost_total.to_f / @total_sales_revenue).round(3))*100
    else
      @margin = 0
    end
  end

  def require_admin
    if !current_user.has_role?('Admin') and !current_user.has_role?('ServiceLineResp')
      render(:text=>"You're not allowed to view this page. This is sad.")
      return
    end
  end

end
