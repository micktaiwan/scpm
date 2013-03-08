class AddSuiteIdToProjects < ActiveRecord::Migration
  def self.up
  	add_column :projects, :suite_tag_id, :integer
  end

  def self.down
  	remove_column :projects, :suite_tag_id
  end
end
