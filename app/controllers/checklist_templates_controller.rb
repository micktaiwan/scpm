class ChecklistTemplatesController < ApplicationController

  layout 'tools'

  def index
    @templates = ChecklistItemTemplate.find(:all, :conditions=>"parent_id=0")
  end

  def new
    @ctemplate = ChecklistItemTemplate.new
  end

  def create
    @ctemplate = ChecklistItemTemplate.new(params[:ctemplate])
    if not @ctemplate.save
      render :action => 'new'
      return
    end
    redirect_to('/checklist_templates')
  end
end

