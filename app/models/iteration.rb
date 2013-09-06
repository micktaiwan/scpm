class Iteration < ActiveRecord::Base

	def project
		Project.find_by_project_code(self.project_code)
	end
end
