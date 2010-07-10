class AddProjectIdToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :project_id, :integer, :default=>nil
  end

  def self.down
    remove_column :requests, :project_id
  end
end

