class MilestoneName < ActiveRecord::Base
  has_many    :checklist_item_template_milestone_name, :dependent=>:destroy
  has_many    :checklist_item_templates, :through => :checklist_item_template_milestone_name
  has_many    :question_references
end
