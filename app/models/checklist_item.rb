class ChecklistItem < ActiveRecord::Base

  has_many :children, :class_name=>"ChecklistItem", :foreign_key=>"parent_id"
  belongs_to :ctemplate, :class_name=>"ChecklistItemTemplate", :foreign_key=>"template_id"
  belongs_to :milestone
  belongs_to :parent, :class_name=>"ChecklistItem"

  def css_class
    case
      when self.ctemplate.ctype=='folder'
        'checklist_item folder'
      when self.status > 0
        'checklist_item done'
      else
        'checklist_item'
    end
  end

  def image_name
    self.ctemplate.values.image(self.status)
  end

  def alt
    self.ctemplate.values.alt(self.status)
  end

  def good?
    return false if !self.milestone
    return false if !self.ctemplate
    return false if !self.ctemplate.milestone_names.map{|m| m.title}.include?(self.milestone.name)
    return true
  end

end

