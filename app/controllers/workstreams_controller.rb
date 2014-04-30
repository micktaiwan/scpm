class WorkstreamsController < ApplicationController

  before_filter :require_login
  layout 'tools'
  
  def index
    @ws = Workstream.find(:all, :order=>'name')
  end

  def manage
    @ws = Workstream.find(:all, :order=>'name')
  end

  def new
    @ws = Workstream.new
  end

  def edit
    @ws = Workstream.find(params[:id])
  end

  def create
    @workstream = Workstream.new(params[:ws])
    if not @workstream.save
      render :action => 'new'
      return
    end
    redirect_to("/workstreams/manage")
  end

  def delete
    id = params[:id]
    @ws = Workstream.find(id)
    @ws.destroy
    redirect_to "/workstreams/manage"
  end

  def update
    id = params[:id]
    @ws = Workstream.find(id)
    if @ws.update_attributes(params[:ws]) # do a save
      redirect_to "/workstreams/manage"
    else
      render :action => 'edit'
    end
  end
  
  def copy_status_to_reporting
    last_status = Project.find(params[:id]).get_status
    last_status.copy_status_to_reporting if last_status
    render(:nothing=>true)
  end

end
