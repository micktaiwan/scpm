class ActionsController < ApplicationController

  before_filter :require_login

  def index
    @actions              = Action.find(:all, :conditions=>["person_id=? and progress in('open','in_progress')", current_user.id], :order=>"creation_date")
    @actions_closed       = Action.find(:all, :conditions=>["person_id=? and progress in('closed','abandonned')", current_user.id], :order=>"creation_date")
    @other_actions        = Action.find(:all, :conditions=>["person_id!=? and progress in('open','in_progress')",current_user.id], :order=>"creation_date")
    @other_actions_closed = Action.find(:all, :conditions=>["person_id!=? and progress in('closed','abandonned')",current_user.id], :order=>"creation_date")
  end

  def new
    @myaction = Action.new(:private=>1, :person_id=>current_user.id, :project_id=>params[:project_id], :progress=>:open, :creation_date=>Date.today(), :due_date=>Date.today()+7)
    get_infos
  end

  def create
    @myaction = Action.new(params[:myaction])
    if not @myaction.save
      render :action => 'new', :project_id=>params[:myaction][:project_id]
      return
    end
    redirect_to("/projects/show/#{@myaction.project_id}")
  end

  def edit
    id = params[:id]
    @myaction = Action.find(id)
    get_infos
  end

  def update
    a = Action.find(params[:id])
    a.update_attributes(params[:myaction])
    redirect_to "/projects/show/#{a.project_id}"
  end

  def destroy
    Action.find(params[:id].to_i).destroy
    render(:nothing=>true)
  end

  def cut
    session[:action_cut] = params[:id]
    session[:cut] = nil
    session[:status_cut] = nil
    session[:request_cut] = nil
  end

  private

  def get_infos
    @people = Person.find(:all, :order=>"name")
    @projects = Project.find(:all)
    @projects_select = @projects.map {|u| [u.workstream + " " + u.full_name,u.id]}.sort_by { |n| n[0]}
  end

end
