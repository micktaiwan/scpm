class ActionsController < ApplicationController

  def new
    @myaction = Action.new(:project_id=>params[:project_id], :progress=>:open, :creation_date=>Date.today(), :due_date=>Date.today()+7)
    @people = Person.find(:all, :order=>"name")
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
    @people = Person.find(:all, :order=>"name")
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

  
end
