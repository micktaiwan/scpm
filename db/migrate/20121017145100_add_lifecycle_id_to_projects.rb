class AddLifecycleIdToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :lifecycle_id, :integer
  end

  def self.down
    remove_column :projects, :lifecycle_id
  end
end
