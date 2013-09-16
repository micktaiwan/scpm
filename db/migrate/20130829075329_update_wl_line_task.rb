class UpdateWlLineTask < ActiveRecord::Migration
	def self.up
		 wl_lines = WlLine.find(:all, :conditions=>["sdp_task_id is not null"])
		 wl_lines.each do |line|
		 	line_task = WlLineTask.create(:wl_line_id=>line.id,:sdp_task_id=>line.sdp_task_id)
		 end
	end

	def self.down
		WlLineTask.find(:all).each {|p| p.destroy}
	end
end

