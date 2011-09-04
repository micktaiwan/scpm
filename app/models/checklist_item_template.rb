class ChecklistItemTemplate < ActiveRecord::Base

  has_many :children, :class_name=>"ChecklistItemTemplate", :foreign_key=>"parent_id"

end

