module ProjectsHelper

  def are_filtered
    session[:project_filter_workstream] or session[:project_filter_status] or session[:project_filter_supervisor] or session[:project_filter_qr] or session[:project_filter_text]
  end

end
