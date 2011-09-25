class GenericRiskQuestionsController < ApplicationController

  layout 'tools'

  def index
    @questions = GenericRiskQuestion.all
  end

  def new
    @question = GenericRiskQuestion.new
  end

  def create
    @question = GenericRiskQuestion.new(params[:question])
    if not @question.save
      render :action => 'new'
      return
    end
    redirect_to("/generic_risk_questions")
  end

  def edit
    id = params[:id]
    @question = GenericRiskQuestion.find(id)
  end

  def update
    q = GenericRiskQuestion.find(params[:id])
    q.update_attributes(params[:question])
    redirect_to "/generic_risk_questions"
  end

  def destroy
    GenericRiskQuestion.find(params[:id].to_i).destroy
    render(:nothing=>true)
  end

  def apply
    @project = Project.find(params[:id])
    @questions = GenericRiskQuestion.all
    render(:layout=>'general')
  end

end

