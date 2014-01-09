class ItemTemplateValue

  attr_accessor :options, :images

  def initialize
    @options  = ['Not done yet','Done','Will not be done']
    @images   = ['cb0.gif','cb1.gif','cb2.gif']
  end

  def image(value)
    @images[value]
  end

  def alt(value)
    @options[value]
  end

  def next_value(value)
    n = value + 1
    n = 0 if n >= @options.size
    n
  end

end

class ChecklistItemTemplate < ActiveRecord::Base

  belongs_to  :parent, :class_name=>"ChecklistItemTemplate"
  has_many    :children, :class_name=>"ChecklistItemTemplate", :foreign_key=>"parent_id", :order=>"`order`", :dependent=>:nullify
  has_many    :checklist_items, :class_name=>"ChecklistItem", :foreign_key=>"template_id", :dependent=>:nullify
  has_many    :checklist_item_template_workpackages, :dependent=>:destroy
  has_many    :workpackages, :through => :checklist_item_template_workpackages
  has_many    :checklist_item_template_milestone_names, :dependent=>:destroy
  has_many    :milestone_names, :through => :checklist_item_template_milestone_names
  serialize   :values, ItemTemplateValue

  def initialize(arg=nil)
    super(arg)
    self.values = ItemTemplateValue.new if !self.values
  end

  def mydestroy
    ChecklistItem.destroy_all(["template_id=?",self.id])
    self.children.each(&:mydestroy)
    self.destroy
  end

  def full_path
    return self.title if not self.parent or self.parent_id == 0
    self.parent.full_path + " > " + self.title
  end

  def has_ancestor?(id)
    return false if !self.parent
    return true if self.parent_id == id
    return self.parent.has_ancestor?(id)
  end

  # return all Requests fitting the template conditions
  def requests
    Request.find(:all, :conditions=>"resolution!='aborted' and resolution!='ended' and status='assigned'").select { |r|
      self.workpackages.map{|w| w.title}.include?(r.work_package)
      }
  end

  def check_parent
    return if !self.parent
    diff = (self.milestone_names - self.parent.milestone_names) + (self.workpackages - self.parent.workpackages)
    raise "Parent of #{self.title} does not contains:\n#{diff.map{|i| i.title}.join(', ')}" if (diff) != []
  end


  # 
  # Deploy parents
  #

  # Deploy this checklist item template as parent for each projects/milestones is_qr_qwr
  def deploy_as_parent_is_qr_qwr
    for project in Project.find(:all, :conditions => ["is_qr_qwr = 1"]).select { |p| !p.is_ended}
      project.milestones.select{ |m1| m1.checklist_not_applicable==0 and m1.status==0 and m1.done==0 and self.milestone_names.map{|mn| mn.title}.include?(m1.name)}.each do |milestone|
        i = ChecklistItem.find(:first, :conditions=>["template_id=? and milestone_id=? and request_id IS NULL and project_id IS NULL", self.id, milestone.id])
        if i == nil
          ChecklistItem.create(:milestone_id=>milestone.id, :parent_id=>0, :template_id=>self.id)
        end
      end
    end
  end

  # Deploy this checklist item template as parent for each requests
  def deploy_as_parent_request
    # Each requests found for this template
    self.requests.each { |r|
      # Each milestones linked to this request
      r.milestones.select{ |m1| 
          m1.checklist_not_applicable==0 and m1.status==0 and m1.done==0  and (r.contre_visite=="No" or r.contre_visite_milestone==m1.name) and self.milestone_names.map{|mn| mn.title}.include?(m1.name)
        }.each { |m|
        p = ChecklistItem.find(:first, :conditions=>["template_id=? and request_id=? and milestone_id=?", self.id, r.id, m.id])
        if p == nil
          ChecklistItem.create(:milestone_id=>m.id, :request_id=>r.id, :parent_id=>0, :template_id=>self.id)
        end
      }
    }
  end

  # Deploy this checklist for each projects as parent
  def deploy_as_parent_is_transverse
    for project in Project.all.select { |p| !p.is_ended}
      i = ChecklistItem.find(:first, :conditions=>["template_id=? and project_id=? and request_id IS NULL and milestone_id IS NULL", self.id, project.id])
      if i == nil
        ChecklistItem.create(:project_id=>project.id, :parent_id=>0, :template_id=>self.id)
      end
    end
  end

  # 
  # Deploy childs
  #

  # Deploy this checklist item template as child for each projects/milestones is_qr_qwr
  def deploy_as_childs_is_qr_qwr
    # Each projects
    for project in Project.find(:all, :conditions => ["is_qr_qwr = 1"]).select { |p| !p.is_ended}
      # Each milestones
      project.milestones.select{ |m1| m1.checklist_not_applicable==0 and m1.status==0 and m1.done==0 and self.milestone_names.map{|mn| mn.title}.include?(m1.name)}.each do |milestone|
        i = ChecklistItem.find(:first, :conditions=>["template_id=? and milestone_id=? and request_id IS NULL and project_id IS NULL", self.id, milestone.id])
        # Create
        if i == nil
          # Get the parent
          parent = ChecklistItem.find(:first, :conditions=>["template_id=? and milestone_id=? and request_id IS NULL and project_id IS NULL", self.parent.id, milestone.id])
          if parent
            ChecklistItem.create(:milestone_id=>milestone.id, :parent_id=>parent.id, :template_id=>self.id)
          end
        # Update
        else
          parent = ChecklistItem.find(:first, :conditions=>["template_id=? and milestone_id=? and request_id IS NULL and project_id IS NULL", self.parent.id, milestone.id])
          if parent
            i.parent_id = parent.id
            i.save
          end
        end
      end
    end
  end

  # Deploy this checklist item template as childs for each requests
  def deploy_as_childs_request
    # Each requests found for this template
    self.requests.each { |r|
      # Each milestones linked to this request
      r.milestones.select{ |m1| 
        m1.checklist_not_applicable==0 and m1.status==0 and m1.done==0 and (r.contre_visite=="No" or r.contre_visite_milestone==m1.name) and self.milestone_names.map{|mn| mn.title}.include?(m1.name)
        }.each { |m|
        c = ChecklistItem.find(:first, :conditions=>["template_id=? and request_id=? and milestone_id=?", self.id, r.id, m.id])
        # Create
        if c == nil
          parent = ChecklistItem.find(:first, :conditions=>["template_id=? and request_id=? and milestone_id=?", self.parent.id, r.id, m.id])
          if parent
            ChecklistItem.create(:milestone_id=>m.id, :request_id=>r.id, :parent_id=>parent.id, :template_id=>self.id)
          end
        # Update
        else
          parent = ChecklistItem.find(:first, :conditions=>["template_id=? and request_id=? and milestone_id=?", self.parent.id, r.id, m.id])
          if parent
            c.parent_id = parent.id
            c.save
          end
        end
      }
    }
  end

  # Deploy this checklist for each projects as child
  def deploy_as_childs_is_transverse
      for project in Project.all.select { |p| !p.is_ended}
        i = ChecklistItem.find(:first, :conditions=>["template_id=? and project_id=? and request_id IS NULL and milestone_id IS NULL", self.id, project.id])
        if i == nil
          parent = ChecklistItem.find(:first, :conditions=>["template_id=? and project_id=? and request_id IS NULL and milestone_id IS NULL", self.parent.id, project.id])
          if parent
            ChecklistItem.create(:project_id=>project.id, :parent_id=>parent.id, :template_id=>self.id )
          end
        else
          parent = ChecklistItem.find(:first, :conditions=>["template_id=? and project_id=? and request_id IS NULL and milestone_id IS NULL", self.parent.id, project.id])
          if parent
            i.parent_id = parent.id
            i.save
          end
        end
      end
  end


  def items_done_count
    ChecklistItem.find(:all, :include=>["milestone", "request"], :conditions=>["template_id=?", self.id]).select { |i| i.milestone and i.milestone.done==1 and i.request.contre_visite=="No"}.size
  end
  
  def items_values_count(value)
    ChecklistItem.find(:all, :include=>["milestone", "request"], :conditions=>["template_id=? and status=?", self.id, value]).select { |i| i.milestone and i.milestone.done==1 and i.request.contre_visite=="No"}.size
  end
  
  PIE_COLORS = ['DD6666', '2FAF24', 'BBBBBB', '3F9EA0', 'D29900']
  def partition_graph_url
    chart = GoogleChart::PieChart.new('250x250', nil, false)
    self.values.options.each_with_index do |d,i|
      chart.data d, self.items_values_count(i), PIE_COLORS[i]
    end
    chart.show_legend = true
    chart.show_labels = false
    chart.to_url
  end

end

