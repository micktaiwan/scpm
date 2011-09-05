class CreateChecklistItemTemplateWorkpackages < ActiveRecord::Migration
  def self.up
    create_table :checklist_item_template_workpackages do |t|
      t.integer :checklist_item_template_id
      t.integer :workpackage_id
    end
  end

  def self.down
    drop_table :checklist_item_template_workpackages
  end
end

