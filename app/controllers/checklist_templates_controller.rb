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
- Don\'t know"
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
      old_nb_options = @ctemplate.values.options ? @ctemplate.values.options.size : 0
      @ctemplate.update_attributes(params[:ctemplate])
      new_nb = @ctemplate.values.options ? @ctemplate.values.options.size : 0
      if old_nb_options > new_nb
        # careful when you are editing a template ! All previous values are lost.
        reset_checklist_items_values(@ctemplate.id)
      end
      @ctemplate.deployed = 0
      # destroy and recreate associations (later)
      @ctemplate.checklist_item_template_milestone_names.each(&:destroy)
      @ctemplate.checklist_item_template_workpackages.each(&:destroy)
    end
    # create associations
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

  def reset_checklist_items_values(template_id)
    ChecklistItem.update_all("status=0", ["template_id=?",template_id])
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

  def deploy_all
    check_parents
    deploy_parents
    deploy_childs
    render(:nothing=>true)
  end
  
  def deploy_parent_and_childs
    parent = ChecklistItemTemplate.find(:first, :conditions=>["id = ?", params[:ctemplate_id]])
    if parent
      check_parents(parent)
      deploy_parents(parent)
      deploy_childs(parent)
    end
    render(:nothing=>true)
  end

  # Check parents
  def check_parents(parent = nil)
    if parent != nil
      ChecklistItemTemplate.find(:all, :conditions=>["id = ?",parent.id.to_s]).each do |ct|
        ct.check_parent
      end
    else
      ChecklistItemTemplate.find(:all).each do |ct|
        ct.check_parent
      end
    end
  end

  #
  # DEPLOY PARENTS 
  #
  def deploy_parents(parent = nil)
    self.deploy_parents_is_qr_qwr(parent)
    self.deploy_parents_request(parent)
    self.deploy_parents_is_transverse(parent)
  end

  # Deploy all checklistitemtemplate for is qr qwr
  def deploy_parents_is_qr_qwr(parent = nil)

    query = "parent_id = 0 and is_qr_qwr = 1 and is_transverse = 0"
    if parent != nil
      query += " and id = " + parent.id.to_s
    end
    
    ChecklistItemTemplate.find(:all,:conditions=>[query]).each do |ct|
      ct.deploy_as_parent_is_qr_qwr
    end      
  end

  # Deploy all checklistitemtemplate for requests
  def deploy_parents_request(parent = nil)
    
    query = "parent_id = 0 and is_transverse = 0"
    if parent != nil
      query += " and id = " + parent.id.to_s
    end

    ChecklistItemTemplate.find(:all,:conditions=>[query]).each do |ct|
      ct.deploy_as_parent_request
    end
  end
  
  # Deploy all checklistitemtemplate for is transverse
  def deploy_parents_is_transverse(parent = nil)

    query = "parent_id = 0 and is_transverse = 1"
    if parent != nil
      query += " and id = " + parent.id.to_s
    end

    ChecklistItemTemplate.find(:all,:conditions=>[query]).each do |ct|
      ct.deploy_as_parent_is_transverse
    end
  end

  # 
  # DEPLOY CHILDS
  # 
  def deploy_childs(parent = nil)
    self.deploy_childs_is_qr_qwr(parent)
    self.deploy_childs_request(parent)
    self.deploy_childs_is_transverse(parent)
  end

  def deploy_childs_is_qr_qwr(parent = nil)

    query = "parent_id != 0 and is_qr_qwr = 1 and is_transverse = 0"
    if parent != nil
      query += " and parent_id = " + parent.id.to_s
    end

    ChecklistItemTemplate.find(:all,:conditions=>[query]).each do |ct|
      ct.deploy_as_childs_is_qr_qwr
    end   
  end

  def deploy_childs_request(parent = nil)

    query = "parent_id != 0 and is_transverse = 0"
    if parent != nil
      query += " and parent_id = " + parent.id.to_s
    end

    ChecklistItemTemplate.find(:all,:conditions=>[query]).each do |ct|
      ct.deploy_as_childs_request
    end
  end

  def deploy_childs_is_transverse(parent = nil)

    query = "parent_id != 0 and is_transverse = 1"
    if parent != nil
      query += " and parent_id = " + parent.id.to_s
    end

    ChecklistItemTemplate.find(:all,:conditions=>[query]).each do |ct|
      ct.deploy_as_childs_is_transverse
    end
  end

  def indicators
    @templates = ChecklistItemTemplate.find(:all, :conditions=>"is_transverse=0 and parent_id!=0", :order=>"is_transverse, `order`, id")
    @template_count = @templates.size
  end
  
  def ind_details
    template_id = params[:id]
    @ctemplate  = ChecklistItemTemplate.find(template_id)
    @items      = @ctemplate.checklist_items.select{|i| i.milestone.done==1 and i.request.contre_visite=="No"}.sort_by{ |i| [i.milestone.project.full_name, i.milestone.name]}
    @values     = @items.map{|i| [i.status, i.ctemplate.values.alt(i.status)]}.uniq
  end
  
  def list_per_wp_filter
    @workpackages = Workpackage.all.sort_by { |w| [ w.title ] }
    @milestones = MilestoneName.all.sort_by { |m| [ m.title ] }
    @checklists = ChecklistItemTemplate.all( :conditions => ["parent_id = 0 or parent_id = null"])
  end
  
  def list_per_wp
    if !params[:workpackages] or !params[:milestones] or !params[:checklists]
      redirect_to :action => "list_per_wp_filter"
      return
    else
      workpages_filtered  = Workpackage.find(params[:workpackages])
      milestones_filtered = MilestoneName.find(params[:milestones])
      checklists_filtered = ChecklistItemTemplate.find(:all, :conditions => ["(parent_id = 0 or parent_id = null) and id IN (?)",params[:checklists]])
      @workpackages = workpages_filtered.sort_by { |w| [ w.title ] }
      @milestones = milestones_filtered.sort_by { |m| [ m.title ] }
      @checklists = checklists_filtered
    end
  end
end


