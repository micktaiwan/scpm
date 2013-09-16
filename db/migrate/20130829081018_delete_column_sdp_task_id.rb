class DeleteColumnSdpTaskId < ActiveRecord::Migration
  def self.up
  	remove_column :wl_lines, :sdp_task_id
  end

  def self.down
	add_column :wl_lines, :sdp_task_id, :integer
	line_tasks = WlLineTask.all
	line_tasks.each do |l|
	  jointer = WlLine.find(l.wl_line_id)
	  jointer.sdp_task_id = l.sdp_task_id
	  jointer.save
	end
  end
end
