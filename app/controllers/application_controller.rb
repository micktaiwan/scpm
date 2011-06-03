# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'will_paginate'
require 'differ'
Differ.format = :html

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  layout 'general'
  include Authentication
  before_filter :log_action
  before_filter :verify_auth
  before_filter :set_timezone

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  def set_timezone
    Time.zone = 'Paris'
  end
  
  def verify_auth
    redirect_to "/sessions/login" and return if(not current_user and controller_name != "sessions") 
  end
  
  def log_action
    return if controller_name == "chat" and (action_name == "refresh_sessions" or action_name == "refresh")
    @action_log                   = Log.new
    # who is doing the activity?
    @action_log.person_id         = session[:user_id]
    @action_log.session_id        = request.session_options[:id] #record the session
    @action_log.browser           = request.env['HTTP_USER_AGENT']
    @action_log.ip                = request.env['HTTP_X_FORWARDED_FOR'] || request.env['REMOTE_ADDR']
    # what are they doing?
    @action_log.controller        = controller_name
    @action_log.action            = action_name
    @action_log.controller_action = controller_name + "/" + action_name
    @action_log.params            = params.inspect # wrap this in an unless block if it might contain a password
    @action_log.save!
  end

end

class MyLinkRenderer < WillPaginate::LinkRenderer

  def page_link(page, text, attributes = {})
    @template.link_to_remote(text, {:url=>{:page=>page}}, attributes)
  end

end

def month_loop(month, year, mode=:one_date)
  today     = Date.today()
  begin
    from =  Date.new(year,month,1)
    to   =  (Date.new(year,month,1) + 1.month) - 1.day
    if mode == :two_dates
      yield(from,to)
    else  
      yield(to)
    end
    month += 1
    if month > 12
      month = 1
      year += 1
    end
  end while year < today.cwyear or (year == today.cwyear and month <= today.month)
end
