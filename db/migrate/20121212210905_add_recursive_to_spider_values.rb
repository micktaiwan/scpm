class AddRecursiveToSpiderValues < ActiveRecord::Migration
  def self.up
  	add_column :spider_values, :recursive, :boolean, :default => false
  end

  def self.down
  	remove_column :spider_values, :recursive
  end
end
