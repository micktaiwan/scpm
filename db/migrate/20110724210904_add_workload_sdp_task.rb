class AddWorkloadSdpTask < ActiveRecord::Migration
  def self.up
    add_column :wl_lines, :sdp_task_id, :integer
  end

  def self.down
    remove_column :wl_lines, :sdp_task_id
  end
end

