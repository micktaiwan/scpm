class DeleteColumnSdpTaskId < ActiveRecord::Migration
  def self.up
  	remove_column :wl_lines, :sdp_task_id
  end

  def self.down
  end
end
