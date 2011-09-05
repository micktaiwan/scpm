class CreateChecklistItemTemplateMilestones < ActiveRecord::Migration
  def self.up
    create_table :checklist_item_template_milestone_names do |t|
      t.integer   :checklist_item_template_id
      t.integer   :milestone_name_id
    end
  end

  def self.down
    drop_table :checklist_item_template_milestone_names
  end
end
