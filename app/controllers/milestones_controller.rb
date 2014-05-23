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
    redirect_to("/projects/show/#{@params[:id]}")
  end

  def edit
    id = params[:id]
    @milestone = Milestone.find(id)

    @date_error = params[:date_error]
    params[:date_error] ? @date_error = params[:date_error] : @date_error = 0

    get_infos
  end

  def update
    m   = Milestone.find(params[:id])
    old = m.done

    error = false;

    # Try to update the date, if wrong format = remote
    if params[:milestone][:milestone_date] and params[:milestone][:milestone_date].length > 0
      begin
        date_bdd = Date.parse(params[:milestone][:milestone_date]).strftime("%Y-%m-%d %H:%M:%S")
        if date_bdd
          m.milestone_date = date_bdd
        else
          raise 'Date format error'
        end
      rescue ArgumentError
        error = true
      end
    end

    if params[:milestone][:actual_milestone_date] and params[:milestone][:actual_milestone_date].length > 0
      begin
        date_bdd = Date.parse(params[:milestone][:actual_milestone_date]).strftime("%Y-%m-%d %H:%M:%S")
        if date_bdd
          m.actual_milestone_date = date_bdd
        else
          raise 'Date format error'
        end
      rescue ArgumentError 
        error = true
      end
    end

    # If no date error
    if !error
      # Update parameters
      if params[:milestone][:project_id]
        m.project = Project.find(params[:milestone][:project_id])
      end

      if params[:milestone][:name]
        m.name = params[:milestone][:name]
      end

      if params[:milestone][:comments]
        m.comments = params[:milestone][:comments]
      end

      if params[:milestone][:status]
        m.status = params[:milestone][:status]
      end

      if params[:milestone][:done]
        m.done = params[:milestone][:done]
      end

      if params[:milestone][:checklist_not_applicable]
        m.checklist_not_applicable = params[:milestone][:checklist_not_applicable]
      end

      # Save
      m.save true

      # Redirect
      if m.done == 1 and old == 0 and m.is_eligible_for_note?
        redirect_to "/notes/new?project_id=#{m.project_id}&done=1"
      else
        redirect_to "/projects/show/#{m.project_id}"
      end
    else
      # Date error
      redirect_to("/milestones/edit?id=#{params[:id]}&date_error=1")
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
