class MilestonesController < ApplicationController

  before_filter :require_login

  # def index
    # @milestones = Milestone.find(:all, :order=>"done, id")
  # end

  def new
    @milestone = Milestone.new(:project_id=>params[:project_id], :milestone_date=>Date.today(), :name=>'m3')
    get_infos
  end

  def create
    @milestone = Milestone.new(params[:milestone])
    if not @milestone.save
      render :action => 'new', :project_id=>params[:milestone][:project_id]
      return
    end
    redirect_to("/projects/show/#{@milestone.project_id}")
  end

  def edit
    id = params[:id]
    @milestone = Milestone.find(id)
    get_infos
  end

  def update
    a = Milestone.find(params[:id])
    a.update_attributes(params[:milestone])
    redirect_to "/projects/show/#{a.project_id}"
  end

  def destroy
    Milestone.find(params[:id].to_i).destroy
    render(:nothing=>true)
  end

  private

  def get_infos
    @projects = Project.find(:all)
    @projects_select = @projects.map {|u| [u.workstream + " " + u.full_name,u.id]}.sort_by { |n| n[0]}
  end

end
