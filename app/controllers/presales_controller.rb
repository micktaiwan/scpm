class PresalesController < ApplicationController
	layout "tools"
	def index
		@projects_with_presales = Project.find(:all, :joins=>"JOIN presales ON projects.id = presales.project_id", :conditions=>["is_running=1 and projects.project_id IS NULL"])
		@projects_without_presales = Project.find(:all, :joins=>"LEFT JOIN presales ON projects.id = presales.project_id", :conditions=>"presales.project_id IS NULL and is_running=1 and projects.project_id IS NULL")
	end

	def show_presale
		# Project
		@project_id = params[:id]
		@project = Project.find(:first, :conditions => ["id = ?", @project_id])

		# Presale
		@presale = Presale.find(:first, :conditions => ["project_id = ?", @project_id])
		if @project && !@presale
			@presale = Presale.init_with_project(@project_id)
		end

	end

	def show_presale_type_select
		@presale = Presale.find(:first, :conditions => ["id = ?", params[:id]])
		@presale_types = PresaleType.find(:all)
	end

	def show_presale_by_type
		# Type
		presale_presale_type_id = params[:presale_presale_type]
		@presale_presale_type = PresalePresaleType.find(:first, :conditions => ["id = ?", presale_presale_type_id])
		@presale = Presale.find(:first, :conditions => ["id = ?", @presale_presale_type.presale_id])
		@milestone_names = MilestoneName.find(:all)
		@status = Array.new
		for i in 0..10
			@status << ["#{i*10} %"]
		end
		@complexity = ["Easy", "Medium", "Complex"]

	end

	def update_presale_presale_type
		presalePresaleType = PresalePresaleType.find(:first, :conditions => ["id = ?", params[:presale_presale_type][:id]])
	    presalePresaleType.update_attributes(params[:presale_presale_type])
	    presalePresaleType.save
	    redirect_to :action=>:show_presale_by_type, :presale_presale_type=>presalePresaleType.id
	end

	def create_presale_presale_type
		presale_id = params[:presale_id]
		presale = Presale.find(:first, :conditions => ["id = ?", presale_id])

		presale_type_id = params[:presale_type_id]
		presale_type = PresaleType.find(:first, :conditions => ["id = ?", presale_type_id])

		if presale && presale_type
			presale_presale_type = PresalePresaleType.new
			presale_presale_type.presale = presale
			presale_presale_type.presale_type = presale_type
			presale_presale_type.save
			redirect_to :action=>:show_presale_by_type, :presale_presale_type=>presale_presale_type.id
		else
			redirect_to :action=>:index
		end
	end
end
