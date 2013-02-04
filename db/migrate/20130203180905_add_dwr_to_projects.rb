class AddDwrToProjects < ActiveRecord::Migration
  def self.up
  	add_column :projects, :dwr, :string
  end

  def self.down
  	remove_column :projects, :dwr
  end
end
