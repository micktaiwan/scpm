class ChecklistItem < ActiveRecord::Base

  has_many :children, :class_name=>"ChecklistItem", :foreign_key=>"parent_id"
  belongs_to :ctemplate, :class_name=>"ChecklistItemTemplate", :foreign_key=>"template_id"
  belongs_to :milestone
  belongs_to :request
  belongs_to :project
  belongs_to :parent, :class_name=>"ChecklistItem"

  def late?
    (self.status == 0 and self.ctemplate.deadline and self.milestone.date and
    ((self.milestone.date-self.ctemplate.deadline.days) <= Date.today()))
  end

  def css_class
    case
      when self.ctemplate.ctype=='folder'
        'checklist_item folder'
      when self.late?
        'checklist_item late'
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
    return false if !self.ctemplate
    if self.ctemplate.is_transverse == 0
      return false if !self.milestone
      # return false if self.milestone.checklist_not_allowed?
      return false if !self.ctemplate.milestone_names.map{|m| m.title}.include?(self.milestone.name)
    else
      return false if !self.project
    end
    return true
  end

  def isChildrenActive
    self.children.each do |c|
      if c.status != 0
        return true
      end
    end
    return false
  end

end

