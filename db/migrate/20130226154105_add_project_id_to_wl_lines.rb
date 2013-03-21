class AddProjectIdToWlLines < ActiveRecord::Migration
  def self.up
  	add_column :wl_lines, :project_id, :integer
  end

  def self.down
  	remove_column :wl_lines, :project_id
  end
end
