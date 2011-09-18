class CreateChecklistItems < ActiveRecord::Migration
  def self.up
    create_table :checklist_items do |t|
      t.integer :milestone_id
      t.integer :request_id
      t.integer :parent_id
      t.integer :template_id
      t.integer :hidden, :default=>0
      t.integer :status, :default=>0
      t.timestamps
      t.text    :answer
    end
  end

  def self.down
    drop_table :checklist_items
  end
end

