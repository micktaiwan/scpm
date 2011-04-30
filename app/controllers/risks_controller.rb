class RisksController < ApplicationController

  def new
    @risk = Risk.new(:project_id=>params[:project_id])
    get_infos
  end

  def create
    @risk = Risk.new(params[:risk])
    if not @risk.save
      render :action => 'new', :project_id=>params[:risk][:project_id]
      return
    end
    Mailer::deliver_risk_change(@risk)
    redirect_to("/projects/show/#{@risk.project_id}")
  end

  def edit
    id = params[:id]
    @risk = Risk.find(id)
    get_infos
  end

  def update
    r = Risk.find(params[:id])
    r.update_attributes(params[:risk])
    Mailer::deliver_risk_change(r)
    redirect_to "/projects/show/#{r.project_id}"
  end


private

  def get_infos
    @projects = Project.find(:all)
    @projects_select = @projects.map {|u| [u.workstream + " " + u.full_name,u.id]}.sort_by { |n| n[0]}
  end

end
