class WorkstreamsController < ApplicationController

  before_filter :require_login

  def index
    @ws = Workstream.find(:all, :order=>'name')
  end

  def edit
    @ws = Workstream.find(params[:id])
  end

  def update
    id = params[:id]
    @ws = Workstream.find(id)
    if @ws.update_attributes(params[:ws]) # do a save
      redirect_to "/workstreams"
    else
      render :action => 'edit'
    end
  end

end
