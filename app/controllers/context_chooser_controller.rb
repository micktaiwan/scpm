class ContextChooserController < ApplicationController

  layout 'login'

  #def background
  #  render(:text=>"/images/bg/01.jpg")
  #end

  def index
  	@current_actions_from_user = Action.find(:all, :conditions=>["person_id=? and progress in('open','in_progress')", current_user.id], :order=>"creation_date")
  	#@recent_current_actions_from_user = @current_actions_from_user.select { |action| (Time.now - action.creation_date) < 72}
  end


end

