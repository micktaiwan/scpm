class AddQsCountToProjects < ActiveRecord::Migration
  def self.up
  	add_column :projects, :qs_count, :integer, :default=> 0
  end

  def self.down
  	remove_column :projects, :qs_count
  end
end
