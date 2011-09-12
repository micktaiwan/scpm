class WorkstreamsController < ApplicationController

  before_filter :require_login
  layout 'tools'
  
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
  
  def copy_status_to_ws_reporting
    last_status = Project.find(params[:id]).get_status
    last_status.copy_status_to_ws_reporting if last_status
    render(:nothing=>true)
  end

end
