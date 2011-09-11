class AddChecklistTemplateValues < ActiveRecord::Migration
  def self.up
    add_column :checklist_item_templates, :values, :text
    for t in ChecklistItemTemplate.all
      t.values = ItemTemplateValue.new
      t.save
    end
  end

  def self.down
    remove_column :checklist_item_templates, :values
  end
end

