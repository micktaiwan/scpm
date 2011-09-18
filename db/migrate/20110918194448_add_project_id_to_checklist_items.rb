class AddProjectIdToChecklistItems < ActiveRecord::Migration
  def self.up
    add_column :checklist_items, :project_id, :integer, :default=>nil
  end

  def self.down
    remove_column :checklist_items, :project_id
  end
end
