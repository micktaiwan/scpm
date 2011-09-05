class ChecklistItemTemplateWorkpackage < ActiveRecord::Base

  belongs_to :checklist_item_template
  belongs_to :workpackage

end
