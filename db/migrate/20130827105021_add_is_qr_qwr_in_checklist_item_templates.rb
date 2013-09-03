class AddIsQrQwrInChecklistItemTemplates < ActiveRecord::Migration
  def self.up
  	add_column :checklist_item_templates, :is_qr_qwr, :boolean, :default => false
  end

  def self.down
  	remove_column :checklist_item_templates, :is_qr_qwr
  end
end
