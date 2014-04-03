class MonthlyTasksController < ApplicationController
  layout "tools", :except => [:get_people_for_monthly_task]

  # General actions 
  def index
  	@monthlyTasks = MonthlyTask.find(:all)
  end

  def new
  	@monthlyTask = MonthlyTask.new()
  	@people = Person.find(:all, :conditions=>["is_supervisor = 0 and has_left = 0"])
    @monthlyTaskTypes = MonthlyTaskType.find(:all)
  end

  def edit
    id = params[:id]
    @monthlyTask = MonthlyTask.find(id)
    @people = Person.find(:all, :conditions=>["is_supervisor = 0 and has_left = 0"])
    @monthlyTaskTypes = MonthlyTaskType.find(:all)
  end

  def create
    @monthlyTask = MonthlyTask.new(params[:monthlyTask])
    if not @monthlyTask.save
      render :action => 'new'
      return
    end
    redirect_to("/monthly_tasks/index")
  end

  def update
  	monthlyTask = MonthlyTask.find(params[:id])
    monthlyTask.update_attributes(params[:monthlyTask])
    
    redirect_to("/monthly_tasks/index")
  end

  def destroy
    MonthlyTask.find(params[:id].to_i).destroy
    redirect_to("/monthly_tasks/index")
  end


  # Actions buttons / Ajax
  def add_new_person
  	id 			= params[:id]
  	person_id 	= params[:person_id]
	
	  monthlyTask = MonthlyTask.find(id)
	  monthlyTask.add_person(Person.find(person_id))
    render(:nothing=>true)
  end

  def remove_person
  	id 			= params[:id]
  	person_id 	= params[:person_id]
	
	  monthlyTask = MonthlyTask.find(id)
	  monthlyTask.remove_person(Person.find(person_id))
    render(:nothing=>true)
  end

  def get_people_for_monthly_task
  	id 			 = params[:id]
  	@monthlyTask = MonthlyTask.find(id)
  end

end
