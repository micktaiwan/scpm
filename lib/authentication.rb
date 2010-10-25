module Authentication

  def current_user
    return @current_user if @current_user
    if session[:user_id]
      @current_user = Person.find_by_id(session[:user_id].to_i)
      return @current_user
    end
    return nil
  end

  def logged_in?
    current_user != nil
  end

  def require_login
    redirect_to "/sessions/login" unless logged_in?
  end

  def authenticate(login, pwd)
    u = Person.authenticate(login, pwd)
    session[:user_id] = u ? u.id : nil
  end

  def forget_me
    @current_user = nil
    session[:user_id] = nil
  end

end
