class ChecklistItemTemplate < ActiveRecord::Base

  has_many :children, :class_name=>"ChecklistItemTemplate", :foreign_key=>"parent_id", :order=>"`order`", :dependent=>:nullify
  has_many :checklist_item_template_workpackages, :dependent=>:destroy
  has_many :workpackages, :through => :checklist_item_template_workpackages
  has_many :checklist_item_template_milestone_names, :dependent=>:destroy
  has_many :milestone_names, :through => :checklist_item_template_milestone_names
  belongs_to :parent, :class_name=>"ChecklistItemTemplate"#, :foreign_key=>"parent_id"

  def full_path
    return self.title if not self.parent or self.parent_id == 0
    self.parent.full_path + " > " + self.title
  end

  def has_ancestor?(id)
    return false if !self.parent
    return true if self.parent_id == id
    return self.parent.has_ancestor?(id)
  end

end

