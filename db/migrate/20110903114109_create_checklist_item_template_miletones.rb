class CreateChecklistItemTemplateMiletones < ActiveRecord::Migration
  def self.up
    create_table :checklist_item_template_miletones, :id=>false do |t|
      t.integer :checklist_item_template_id
      t.string  :milestone_name
      t.timestamps
    end
  end

  def self.down
    drop_table :checklist_item_template_miletones
  end
end
