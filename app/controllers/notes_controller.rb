class NotesController < ApplicationController

  before_filter :require_login

  def new
    @note = Note.new(:private=>1, :person_id=>current_user.id, :project_id=>params[:project_id])
    @capi_axes = [['Simple Note', -1]]+CapiAxis.find(:all).map{|m| [m.name, m.id]}
    @milestone_done = params[:done]
  end

  def create
    @note = Note.new(params[:note])
    @note.person_id = current_user.id
    if not @note.save
      render :note => 'new', :project_id=>params[:note][:project_id]
      return
    end
    redirect_to("/projects/show/#{@note.project_id}")
  end

  def edit
    id = params[:id]
    @note = Note.find(id)
    @capi_axes = [['Simple Note', -1]]+CapiAxis.find(:all).map{|m| [m.name, m.id]}
  end

  def update
    a = Note.find(params[:id])
    a.update_attributes(params[:note])
    redirect_to "/projects/show/#{a.project_id}"
  end

  def destroy
    Note.find(params[:id].to_i).destroy
    render(:nothing=>true)
  end

  def list
    @notes = Note.find(:all, :conditions=>"capi_axis_id!=-1", :order=>"created_at desc")
  end

  def filter
    if params['id']=="1"
      @notes = Note.find(:all, :conditions=>"capi_axis_id!=-1", :order=>"created_at desc")
    else
      @notes = Note.find(:all, :conditions=>"private=0", :order=>"created_at desc")
    end
    render(:partial=>"capi_table")
  end

end

