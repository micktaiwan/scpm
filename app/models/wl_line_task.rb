class WlLineTask < ActiveRecord::Base

	#belongs_to :sdp_task, :foreign_key=>"sdp_id", :class_name=>"SDPTask"

	def sdp_task
		SDPTask.find_by_sdp_id(self.sdp_task_id)
	end

  def wl_line
    WlLine.find_by_id(self.wl_line_id)
  end

end
