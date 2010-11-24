class AmendmentsController < ApplicationController

  before_filter :require_login

  def index
    @amendments = Amendment.find(:all, :order=>"done, id")
  end

  def new
    @amendment = Amendment.new(:project_id=>params[:project_id])
    get_infos
  end

  def create
    @amendment = Amendment.new(params[:amendment])
    if not @amendment.save
      render :action => 'new', :project_id=>params[:amendment][:project_id]
      return
    end
    redirect_to("/projects/show/#{@amendment.project_id}")
  end

  def edit
    id = params[:id]
    @amendment = Amendment.find(id)
    get_infos
  end

  def update
    a = Amendment.find(params[:id])
    a.update_attributes(params[:amendment])
    redirect_to "/projects/show/#{a.project_id}"
  end

  def destroy
    Amendment.find(params[:id].to_i).destroy
    render(:nothing=>true)
  end

  def cut
    session[:amendment]   = params[:id]
    session[:action_cut]  = nil
    session[:cut]         = nil
    session[:status_cut]  = nil
    session[:request_cut] = nil
  end

  private

  def get_infos
    @projects = Project.find(:all)
    @projects_select = @projects.map {|u| [u.workstream + " " + u.full_name,u.id]}.sort_by { |n| n[0]}
  end


end
