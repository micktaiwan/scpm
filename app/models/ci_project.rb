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
		elsif self.status == "Validated"
			return "ci_project validated"
		end
		""
	end

	def is_late_css
		if self.sqli_validation_date_review and (self.status=="Accepted" or self.status=="Assigned") and self.sqli_validation_date_review <= Date.today()
			return "ci_late_report"
		elsif  self.airbus_validation_date_review and self.status=="Verified" and self.airbus_validation_date_review <= Date.today()
			return "ci_late_report"
		end
		""		
	end

	def self.late_css(date)
		return "" if !date
		return "ci_late" if date <= Date.today()
		""		
	end

	def sqli_delay
		return nil if !self.sqli_validation_date_objective
		return self.sqli_validation_date_review - self.sqli_validation_date_objective
	end

	def airbus_delay
		return nil if !self.airbus_validation_date_objective
		return self.airbus_validation_date_review - self.airbus_validation_date_objective
	end

	def deployment_delay
		return nil if !self.deployment_date_objective
		return self.deployment_date_review - self.deployment_date_objective
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
		when "Validated"
			80
		when "Delivered"
			90
		when "Rejected"
			110
		else	
			0
		end
	end

end
