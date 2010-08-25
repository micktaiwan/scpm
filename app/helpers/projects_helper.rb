module ProjectsHelper

  def are_filtered
    session[:project_filter_workstream] or session[:project_filter_status] or session[:project_filter_supervisor]
  end

end
