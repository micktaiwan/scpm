class AddProjectNameField < ActiveRecord::Migration
  def self.up
    add_column :requests, :project_name, :string
  end

  def self.down
    remove_column :requests, :project_name
  end
end
