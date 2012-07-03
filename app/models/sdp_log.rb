class SdpLog < ActiveRecord::Base

	def css_class
		return "" if Date.today() - self.date < 8
		return " class='sdp_log_late'"
	end

end
