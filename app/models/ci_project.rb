class CiProject < ActiveRecord::Base

	def css_class
		if self.status == "New"
			return "ci_project new"
		elsif self.status == "Accepted"
			return "ci_project acknowledged"
		elsif self.status == "Assigned"
			return "ci_project assigned"
		elsif self.status == "Closed"
			return "ci_project action_closed"
		elsif self.status == "Comment"
			return "ci_project feedback"
		elsif self.status == "Delivered"
			return "ci_project performed"
		elsif self.status == "Rejected"
			return "ci_project cancelled"
		elsif self.status == "Verified"
			return "ci_project to_be_validated"
		end
		""
	end

	def short_stage
		return case self.stage
		when 'Continuous Improvement' 
			"CI"
		when 'BAM' 
			"BAM"
		when 'Request Management Tool' 
			"RMT"
		end

	end

	def order
		return case self.status
		when "New"
			10
		when "Accepted"
			20
		when "Assigned"
			30
		when "Closed"
			100
		when "Comment"
			40
		when "Verified"
			50
		when "Delivered"
			90
		when "Rejected"
			110
		end
	end

end
