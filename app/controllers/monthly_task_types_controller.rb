class MonthlyTaskTypesController < ApplicationController
  layout "tools"

	# General actions 
  def index
  	@monthlyTaskTypes = MonthlyTaskType.find(:all)
  end

  def new
  	@monthlyTaskType = MonthlyTaskType.new()
  end

  def edit
    id = params[:id]
    @monthlyTaskType = MonthlyTaskType.find(id)
  end

  def create
    @monthlyTaskType = MonthlyTaskType.new(params[:monthlyTaskType])
    if not @monthlyTaskType.save
      render :action => 'new'
      return
    end
    redirect_to("/monthly_task_types/index")
  end

  def update
  	monthlyTaskType = MonthlyTaskType.find(params[:id])
    monthlyTaskType.update_attributes(params[:monthlyTaskType])
    
    redirect_to("/monthly_task_types/index")
  end

  def destroy
    MonthlyTaskType.find(params[:id].to_i).destroy
    redirect_to("/monthly_task_types/index")
  end
end
