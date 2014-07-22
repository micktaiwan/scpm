class AddTbpProjectIdToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :tbp_project_id, :integer
  end

  def self.down
    remove_column :projects, :tbp_project_id
  end
end
