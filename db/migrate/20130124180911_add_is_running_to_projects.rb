class AddIsRunningToProjects < ActiveRecord::Migration
  def self.up
  	add_column :projects, :is_running, :boolean, :default=> 1
  end

  def self.down
  	remove_column :projects, :is_running
  end
end
