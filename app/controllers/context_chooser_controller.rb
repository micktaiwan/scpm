class ContextChooserController < ApplicationController

  layout 'login'

  #def background
  #  render(:text=>"/images/bg/01.jpg")
  #end

  def index
    now = DateTime.now
  	@current_actions_from_user = Action.find(:all, :conditions=>["person_id=? and progress in('open','in_progress')", current_user.id], :order=>"creation_date")
  	@actions      = Action.find(:all, :conditions=>["person_id=? and progress in('open','in_progress')", current_user.id])
  	@action_48hr  = Action.find(:all, :conditions=>["person_id=? and progress in('open','in_progress') and updated_at >= ?", current_user.id, now - 48.hours])
  	#@recent_current_actions_from_user = @current_actions_from_user.select { |action| (Time.now - action.creation_date) < 72}
  end


end

