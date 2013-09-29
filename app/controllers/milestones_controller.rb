class MilestonesController < ApplicationController

  before_filter :require_login

  # def index
  #  @milestones = Milestone.find(:all, :order=>"done, id")
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
    m   = Milestone.find(params[:id])
    old = m.done
    m.update_attributes(params[:milestone])
    if m.done == 1 and old == 0 and m.is_eligible_for_note?
      redirect_to "/notes/new?project_id=#{m.project_id}&done=1"
    else
      redirect_to "/projects/show/#{m.project_id}"
    end
  end

  def destroy
    Milestone.find(params[:id].to_i).destroy
    render(:nothing=>true)
  end

  def set_checklist_not_applicable
    id = params[:id]
    m = Milestone.find(id)
    m.update_attribute('checklist_not_applicable',1)
    m.destroy_checklist
    render(:nothing=>true)
  end

  def set_checklist_applicable
    id = params[:id]
    m = Milestone.find(id)
    m.update_attribute('checklist_not_applicable',0)
    m.deploy_checklists
    render(:nothing=>true)
  end

  def deploy_checklists
    id = params[:id]
    Milestone.find(id).deploy_checklists
    render(:nothing=>true)
  end

  def ajax_milestone
    project = Project.find(params[:project_id])
    render(:partial=>'milestones/milestone', :collection=>project.sorted_milestones)
  end

private

  def get_infos
    @projects = Project.find(:all)
    @projects_select = @projects.map {|u| [u.workstream + " " + u.full_name,u.id]}.sort_by { |n| n[0]}
  end

end
