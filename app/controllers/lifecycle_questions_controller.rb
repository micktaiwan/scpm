class LifecycleQuestionsController < ApplicationController
  layout 'tools'
  
  def index
    format_questions()
  end
  
  def format_questions
    @lifecycles = Lifecycle.all.map {|u| [u.name,u.id]}
    
    lifecycle_id = params[:lifecycle_id]
    if !lifecycle_id
      lifecycle_id = Lifecycle.first.id.to_s
    end
    
    @resultsAxes = Hash.new
    @pmTypes = PmType.all
    
    @pmTypes.each do |pm_type|
      @resultsAxes[pm_type.id] = Hash.new
      @resultsAxes[pm_type.id]["axes"] = Hash.new
      @resultsAxes[pm_type.id]["lifecycle_id"] = lifecycle_id.to_s
      @resultsAxes[pm_type.id]["title"] = pm_type.title
      
      PmTypeAxe.find(:all,:conditions=>["pm_type_id = ?",pm_type.id.to_s]).each do |axe|
        @resultsAxes[pm_type.id]["axes"][axe.id] = Hash.new
        @resultsAxes[pm_type.id]["axes"][axe.id]["title"] = axe.title
        @resultsAxes[pm_type.id]["axes"][axe.id]["questions"] = LifecycleQuestion.find(:all,:conditions=>["pm_type_axe_id = ? and lifecycle_id = ?",axe.id,lifecycle_id])  
      end
    end
  end

  def new
    @question = LifecycleQuestion.new
    @pm_type_axes = PmTypeAxe.all.map {|u| [u.title,u.id]}
    @lifecycle_id = params[:lifecycle_id]
    @pm_type_axe_id = params[:pm_type_axe_id]
  end

  def edit
    @question = LifecycleQuestion.find(params[:id])
    @pm_type_axes = PmTypeAxe.all.map {|u| [u.title,u.id]}
    @lifecycle_id = params[:lifecycle_id]
    @pm_type_axe_id = params[:pm_type_axe_id]
  end

  def create
     @question = LifecycleQuestion.new(params[:question])
     if not @question.save
       render :action => 'new'
       return
     end
     
     format_questions()
     render :action => 'index'
  end

  def update
    @question = LifecycleQuestion.find(params[:id])
    if @question.update_attributes(params[:question])
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end

  def destroy
     LifecycleQuestion.find(params[:id]).destroy
     redirect_to :action => "index"
  end

end
