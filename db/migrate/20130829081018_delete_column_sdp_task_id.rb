class DeleteColumnSdpTaskId < ActiveRecord::Migration
  def self.up
  	# remove_column :wl_lines, :sdp_task_id
  end

  def self.down
	# add_column :wl_lines, :sdp_task_id, :integer
	# lines = WlLine.find(:all)
	# lines.each do |l|
	#   jointer = WlLineTask.find(l.id)
	#   l.sdp_task_id = jointer.sdp_task_id if jointer.size==1
	# end
	#
  end
end
