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
    Request.find(:all, :conditions=>"resolution!='ended' and status='assigned'").select { |r|
      self.workpackages.map{|w| w.title}.include?(r.work_package)
      }
  end

  def find_or_deploy_parent(m, r)
    return nil if self.parent_id == 0 or !self.parent_id
    p = ChecklistItem.find(:first, :conditions=>["template_id=? and request_id=? and milestone_id=?", self.parent_id, r.id, m.id])
    return p if p
    self.parent.deploy(false)
    return ChecklistItem.find(:first, :conditions=>["template_id=? and request_id=? and milestone_id=?", self.parent_id, r.id, m.id])
  end

  def check_parent
    return if !self.parent
    diff = (self.milestone_names - self.parent.milestone_names) + (self.workpackages - self.parent.workpackages)
    raise "Parent of #{self.title} does not contains:\n#{diff.map{|i| i.title}.join(', ')}" if (diff) != []
  end

  def deploy(deploy_children=true)
    check_parent
    self.requests.each { |r|
      r.deploy_checklist(self)
      }
    self.update_attributes(:deployed=>1)
    if deploy_children
      self.children.select{|c| c.deployed==0}.each(&:deploy)
    end
  end

end

