class AddColumnColor < ActiveRecord::Migration
  def self.up
  	add_column :tasks, :color, :text
  end

  def self.down
  	remove_column :tasks, :color
  end
end
