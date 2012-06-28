class Workpackage < ActiveRecord::Base
  has_many    :checklist_item_template_workpackages, :dependent=>:destroy
  has_many    :checklist_item_templates, :through => :checklist_item_template_workpackages
end
