class RisksController < ApplicationController

  def new
    @risk = Risk.new(:project_id=>params[:project_id])
    get_infos
  end

  def new_with_stream
    @risk = Risk.new(:stream_id=>params[:stream_id])
    @streams = Stream.find(:all)
  end
  
  def create
    @risk = Risk.new(params[:risk])
    if not @risk.save
      render :action => 'new', :project_id=>params[:risk][:project_id]
      return
    end
    Mailer::deliver_risk_change(@risk)
    redirect_to("/projects/show/#{@risk.project_id}")
  end
  
  def create_with_stream
    @risk = Risk.new(params[:risk])
    if not @risk.save
      render :action => 'new_with_stream', :stream_id=>params[:risk][:stream_id]
      return
    end
    redirect_to("/streams/show_stream_risks/#{@risk.stream_id}")
  end

  def edit
    id = params[:id]
    @risk = Risk.find(id)
    get_infos
  end
  
  def edit_with_stream
    id = params[:id]
    @risk = Risk.find(id)
    @streams = Stream.find(:all)
  end
  
  def update_with_stream
    r = Risk.find(params[:id])
    r.update_attributes(params[:risk])
    redirect_to("/streams/show_stream_risks/#{r.stream_id}")
  end 
  
  def update
    r = Risk.find(params[:id])
    r.update_attributes(params[:risk])
    Mailer::deliver_risk_change(r)
    redirect_to "/projects/show/#{r.project_id}"
  end
  
  def list
    @risks = Risk.find(:all, :conditions=>["stream_id is NULL"], :order=>"probability*impact desc")
    render(:layout=>'tools')
  end
  
  def destroy
    Risk.find(params[:id].to_i).destroy
    render(:nothing=>true)
  end
  
private

  def get_infos
    @projects = Project.find(:all)
    @projects_select = @projects.map {|u| [u.workstream + " " + u.full_name,u.id]}.sort_by { |n| n[0]}
  end

end
