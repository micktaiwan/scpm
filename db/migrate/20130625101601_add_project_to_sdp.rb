class AddProjectToSdp < ActiveRecord::Migration
  def self.up
    add_column :sdp_tasks, :project_code, :string, :length=>10
  end

  def self.down
    remove_column :sdp_tasks, :project_code
  end
end
