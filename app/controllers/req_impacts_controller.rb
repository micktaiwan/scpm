class ReqImpactsController < ApplicationController

  layout 'tools'

  def new
    @requirement_id = params[:id]
    @impact    = ReqImpact.new
  end

  def create
    @impact = ReqImpact.new(params[:impact])
    @impact.person_id = current_user.id
    @errors = nil
    @errors = @impact.errors.full_messages.join("\n") and return if not @impact.save
    redirect_to('/requirements/')
  end

  def edit
    @impact    = ReqImpact.find(params[:id])
  end

  def update
    id = params[:id]
    @impact = ReqImpact.find(id)
    @impact.person_id = current_user.id
    if @impact.update_attributes(params[:impact]) # do a save
      redirect_to "/requirements"
    else
      render :action => 'edit'
    end
  end

end

