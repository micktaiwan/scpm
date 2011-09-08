class ChecklistsController < ApplicationController

  def show
    milestone_id = params[:id]
    @milestone = Milestone.find(milestone_id)
    @checklists = ChecklistItem.find(:all, :conditions=>["milestone_id=? and checklist_items.parent_id=0",milestone_id], :order=>"checklist_item_templates.order", :joins=>"LEFT OUTER JOIN checklist_item_templates ON checklist_item_templates.id=checklist_items.template_id")
    @checklists = @checklists.select{|i| i.ctemplate.ctype!='folder' or i.children.size > 0}
    render(:layout=>false)
  end

  def set_status
    id = params[:id]
    i = ChecklistItem.find(id)
    i.status = params[:status].to_i
    i.save
    render(:nothing=>true)
  end

end

