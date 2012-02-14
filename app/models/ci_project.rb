class CiProject < ActiveRecord::Base

	def css_class
		if self.status == "New"
			return "ci_project new"
		elsif self.status == "Accepted"
			return "ci_project acknowledged"
		elsif self.status == "Assigned"
			return "ci_project assigned"
		else
		end
		""
	end

end
