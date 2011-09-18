class ChecklistTemplatesController < ApplicationController

  layout 'tools'

  def index
    @templates = ChecklistItemTemplate.find(:all, :conditions=>"parent_id=0 or parent_id is null", :order=>"is_transverse")
    @checklist_item_count = ChecklistItem.count
  end

  def new
    parent_id = params[:parent_id]
    @ctemplate = ChecklistItemTemplate.new
    @ctemplate.values = "--- !ruby/object:ItemTemplateValue
images:
- cb0.gif
- cb1.gif
- cb2.gif
- na.jpg
- question.gif
options:
- Not done yet
- Done
- Not done
- N/A
- Don't know"
    if parent_id
      @ctemplate.parent_id = parent_id
      @milestones   = @ctemplate.parent.milestone_names.map{|m| m.title}.join(', ')
      @workpackages = @ctemplate.parent.workpackages.map{|m| m.code}.join(', ')
    end
    @template_select_options = [["No parent", 0]] + ChecklistItemTemplate.find(:all, :select=>"id, title, parent_id").map { |t| [t.full_path,t.id]}.sort_by {|t| t[0]}
  end

  def update
    id = params[:id]
    if not id
      @ctemplate = ChecklistItemTemplate.new(params[:ctemplate])
    else
      @ctemplate = ChecklistItemTemplate.find(params[:id])
      @ctemplate.update_attributes(params[:ctemplate])
      @ctemplate.deployed = 0
      @ctemplate.checklist_item_template_milestone_names.each(&:destroy)
      @ctemplate.checklist_item_template_workpackages.each(&:destroy)
    end
    params[:milestones].split(',').each { |txt|
      m = MilestoneName.find_by_title(txt.strip)
      @ctemplate.milestone_names << m if m and not @ctemplate.milestone_names.include?(m)
      }
    params[:workpackages].split(',').each { |txt|
      m = Workpackage.find_by_code(txt.strip)
      @ctemplate.workpackages << m if m and not @ctemplate.workpackages.include?(m)
      }
    if not @ctemplate.save
      if id
        render :action => 'edit'
      else
        render :action => 'new'
      end
      return
    end
    redirect_to('/checklist_templates')
  end

  def edit
    id = params[:id].to_i
    @ctemplate = ChecklistItemTemplate.find(id)
    parents = ChecklistItemTemplate.find(:all,:conditions=>["id != ?",id], :select=>"id, title, parent_id")
    parents = parents.delete_if{ |t| t.has_ancestor?(id)}
    @template_select_options = [["No parent", 0]] + parents.map { |t| [t.full_path,t.id]}.sort_by {|t| t[0]}
    @milestones   = @ctemplate.milestone_names.map{|m| m.title}.join(', ')
    @workpackages = @ctemplate.workpackages.map{|m| m.code}.join(', ')
  end

  def destroy
    id = params[:id]
    ChecklistItemTemplate.find(id).mydestroy
    render(:nothing=>true)
  end

  def deploy
    id = params[:id]
    begin
      ChecklistItemTemplate.find(id).deploy
    rescue Exception => e
      @error =  e.message
    end
  end

  def deploy_all
    ChecklistItemTemplate.all.each(&:deploy)
    render(:nothing=>true)
  end

end

