class TasksController < ApplicationController

  layout 'pdc'

  def new
    id = params[:id]
    raise "no planning id" if !id
    # TODO
    Task.create(:planning_id=>id, :name=>'New task', :start_date=>Date.today(), :work_in_day=>5)
    redirect_to :controller=>'plannings', :action=>'index', :id=>id
  end

  def edit
  	id = params[:id]
  	@task = Task.find(id)
  end

  def update
    t = Task.find(params[:id])
    t.update_attributes(params[:task])
    redirect_to "/plannings/index/#{t.planning_id}"
  end

  def destroy
    @task = Task.find(params[:id])
    planning_id = @task.planning_id
    @task.destroy
    redirect_to "/plannings/index/#{planning_id}"
  end

end
