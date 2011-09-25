class GenericRisksController < ApplicationController

  layout 'tools'

  def new
    @generic_risk = GenericRisk.new({:generic_risk_question_id=>params[:id]})
  end

  def create
    @generic_risk = GenericRisk.new(params[:generic_risk])
    if not @generic_risk.save
      render :action => 'new'
      return
    end
    redirect_to("/generic_risk_questions")
  end

  def edit
    id = params[:id]
    @generic_risk = GenericRisk.find(id)
  end

  def update
    q = GenericRisk.find(params[:id])
    q.update_attributes(params[:generic_risk])
    redirect_to "/generic_risk_questions"
  end

  def destroy
    GenericRisk.find(params[:id].to_i).destroy
    render(:nothing=>true)
  end

end

