class CreateChecklistItemTemplates < ActiveRecord::Migration
  def self.up
    create_table :checklist_item_templates do |t|
      t.integer     :requirement_id
      t.string      :request_wp # "WP3.2 - Modeling Conception and Production"
      t.integer     :parent_id
      t.string      :type
      t.integer     :is_transverse, :default=>0
      t.string      :title
      t.integer     :deployed, :default=>0
      t.integer     :order, :default=>0
      t.integer     :deadline
      t.timestamps
    end
  end

  def self.down
    drop_table :checklist_item_templates
  end
end
