class CreateChecklistItems < ActiveRecord::Migration
  def self.up
    create_table :checklist_items do |t|
      t.integer :milestone_id
      t.integer :request_id
      t.integer :is_transverse
      t.integer :hidden, :default=>0
      t.integer :parent_id
      t.integer :template_id
      t.date    :deadline
      t.string  :type
      t.text    :answer
      t.integer :status
      t.timestamps
    end
  end

  def self.down
    drop_table :checklist_items
  end
end

