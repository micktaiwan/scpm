class ChecklistItemTemplateMilestoneName < ActiveRecord::Base

  belongs_to :checklist_item_template
  belongs_to :milestone_name

end

