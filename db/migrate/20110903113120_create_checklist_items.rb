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
      t.text    :answer
      t.integer :status
      t.timestamps
    end
  end

# status depends on template ctype
# folder=>{}
# checkbox=>{Todo, Done, Will not be done}

  def self.down
    drop_table :checklist_items
  end
end

