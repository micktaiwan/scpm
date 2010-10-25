class SessionsController < ApplicationController

  layout 'login'

  def login
  end

  def do_login
    authenticate(params[:person][:login], params[:person][:pwd])
    if logged_in?
      redirect_to :controller=>'people'
      return
    end
    redirect_to :action=>:login
  end

  def logout
    forget_me
    redirect_to :action=>:login
  end

end
