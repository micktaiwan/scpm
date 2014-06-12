class PresalesController < ApplicationController
	layout "tools"
	def index
		@projects_with_presales = Project.find(:all, :joins=>"JOIN presales ON projects.id = presales.project_id", :conditions=>["is_running=1 and projects.project_id IS NULL"])
		@projects_without_presales = Project.find(:all, :joins=>"LEFT JOIN presales ON projects.id = presales.project_id", :conditions=>"presales.project_id IS NULL and is_running=1 and projects.project_id IS NULL")


	end

	def show_presale
		@project_id = params[:id]
		@project = Project.find(:first, :conditions => ["id = ?", @project_id])

		@presale = Presale.find(:first, :conditions => ["project_id = ?", @project_id])
		if @project && !@presale
			@presale = Presale.init_with_project(@project_id)
		end
	end

end
