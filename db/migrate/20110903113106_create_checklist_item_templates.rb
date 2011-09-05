class CreateChecklistItemTemplates < ActiveRecord::Migration
  def self.up
    create_table :checklist_item_templates do |t|
      t.integer     :requirement_id
      t.integer     :parent_id
      t.string      :ctype                      # see checklist_items migration
      t.integer     :is_transverse, :default=>0 # if transverse, does not apply to a milestone, but for the whole project
      t.string      :title
      t.integer     :deployed, :default=>0
      t.integer     :order, :default=>0
      t.integer     :deadline                   # nb of days before the milestone
      t.timestamps
    end
  end

  def self.down
    drop_table :checklist_item_templates
  end
end

