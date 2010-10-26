class SessionsController < ApplicationController

  layout 'login'

  def login
  end

  def do_login
    authenticate(params[:person][:login], params[:person][:pwd])
    if logged_in?
      if not current_user.has_role?('Admin')
        session[:project_filter_qr] = [current_user.id] 
        session[:project_sort]      = 'alpha'
      else
        session[:project_filter_qr] = nil
        session[:project_sort]      = nil
      end
      redirect_to :controller=>'projects'
      return
    end
    redirect_to :action=>:login
  end

  def logout
    forget_me
    redirect_to :action=>:login
  end

end
