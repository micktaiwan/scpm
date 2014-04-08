class AddIsActiveToSuiteTags < ActiveRecord::Migration
  def self.up
    add_column :suite_tags, :is_active, :boolean, :default => true
  end

  def self.down
    add_column :suite_tags, :is_active
  end
end
