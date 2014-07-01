class PresalesController < ApplicationController
	layout "tools"
	
	# Projects
	def dashboard
		@opportunities = PresalePresaleType.find(:all)

	end

	def projects
		@presale_presale_type = params[:presale_presale_type]
		

		# Presale Types
		@presale_types = PresaleType.find(:all).map {|pt| [pt.title,pt.id]}

		# Query 
		cond = ""
		if defined?(@presale_presale_type) and @presale_presale_type != nil
			cond = " and presale_presale_types.presale_type_id <> #{@presale_presale_type}" # NOT OK, need to show the projects without Presale or presale presale type.
		end
		@projects = Project.find(:all, 
		                         :joins=>["JOIN milestones ON projects.id = milestones.project_id","LEFT JOIN presales ON projects.id = presales.project_id","LEFT JOIN presale_presale_types ON presales.id = presale_presale_types.presale_id"],
		                         :conditions=>["is_running=1 and projects.project_id IS NOT NULL and milestones.name IN (?)#{cond}", (APP_CONFIG['presale_milestones_priority_setting_up'] + APP_CONFIG['presale_milestones_priority'])], 
		                         :group=>'projects.id')
	end


	def index
		# Requests
		@projects_with_presales = Project.find(:all, :joins=>["JOIN presales ON projects.id = presales.project_id", "JOIN milestones ON projects.id = milestones.project_id"], :conditions=>["is_running=1 and projects.project_id IS NOT NULL and milestones.name IN (?)", (APP_CONFIG['presale_milestones_priority_setting_up'] + APP_CONFIG['presale_milestones_priority'])], :group=>'projects.id')
		
		@projects_without_presales = Project.find(:all, :joins=>["LEFT JOIN presales ON projects.id = presales.project_id", "JOIN milestones ON projects.id = milestones.project_id"], :conditions=>["presales.project_id IS NULL and is_running=1 and projects.project_id IS NOT NULL and milestones.name IN (?)", (APP_CONFIG['presale_milestones_priority_setting_up'] + APP_CONFIG['presale_milestones_priority'])], :group=>'projects.id')

		# Priorities		
		# @priorities_setting_up = Hash.new
		# @priorities = Hash.new

		# @projects_with_presales.each do |p|
		# 	p_priority_setting_up = nil
		# 	p.milestones.select{|m| (APP_CONFIG['presale_milestones_priority_setting_up'] + APP_CONFIG['presale_milestones_priority']) .include? m.name}.each do |m|
		# 		if (APP_CONFIG['presale_milestones_priority_setting_up'].include? m.name)
		# 			p_priority_setting_up = calculPrioritySettingUp(m, p_priority_setting_up)
		# 			@priorities_setting_up[p.id] = p_priority_setting_up
		# 		elsif (APP_CONFIG['presale_milestones_priority'].include? m.name)
		# 			p_priority = calculPriority(m, p_priority)
		# 			@priorities[p.id] = p_priority
		# 		end
		# 	end

		# end
		# @projects_without_presales.each do |p|
		# 	p_priority_setting_up = nil
		# 	p.milestones.select{|m| (APP_CONFIG['presale_milestones_priority_setting_up'] + APP_CONFIG['presale_milestones_priority']).include? m.name}.each do |m|
		# 		if (APP_CONFIG['presale_milestones_priority_setting_up'].include? m.name)
		# 			p_priority_setting_up = calculPrioritySettingUp(m, p_priority_setting_up)
		# 			@priorities_setting_up[p.id] = p_priority_setting_up
		# 		elsif (APP_CONFIG['presale_milestones_priority'].include? m.name)
		# 			p_priority = calculPriority(m, p_priority)
		# 			@priorities[p.id] = p_priority
		# 		end
		# 	end
		# end
	end

	

	# Presale
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
		@lastComment = @presale_presale_type.getLastComment
		@status = Array.new
		for i in 0..10
			@status << ["#{i*10} %"]
		end
		@complexity = ["Easy", "Medium", "Complex"]

	end

	def delete_presale_presale_type
		presalePresaleType = PresalePresaleType.find(:first, :conditions => ["id = ?", params[:id]])
		project_id = presalePresaleType.presale.project.id
	    presalePresaleType.destroy
	    redirect_to :action=>:show_presale, :id=>project_id
	end

	def update_presale_parameter
		presale_parameter_id = params[:presale_parameter_id]
		presale_parameter = PresaleParameter.find(:first, :conditions => ["id = ?", presale_parameter_id])
		if presale_parameter.status == true
			presale_parameter.status = false
		else
			presale_parameter.status = true
		end
		presale_parameter.save
		redirect_to :action=>:show_presale, :id=>presale_parameter.presale.project.id
	end

	# Form callback
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

	def update_presale_comment
		presale_comment = PresaleComment.find(params[:id])
    	presale_comment.comment = params[:presale_comment][:comment]
    	presale_comment.save
    	redirect_to :action=>:show_presale_by_type, :presale_presale_type=>presale_comment.presale_presale_type.id
	end

	def create_presale_comment
		presale_comment       = PresaleComment.create(params[:presale_comment])
		presale_comment.presale_presale_type = PresalePresaleType.find(:first, :conditions => ["id = ?", params[:presale_comment][:presale_presale_type_id]])
		presale_comment.person_id = current_user.id
		presale_comment.save
    	redirect_to :action=>:show_presale_by_type, :presale_presale_type=>presale_comment.presale_presale_type.id
	end

	# Forms
	def presale_comment_edit
		presale_comment_id = params[:id]
		@presale_comment = PresaleComment.find(:first, :conditions => ["id = ?", presale_comment_id])
	end

	def presale_comment_add
	    presale_presale_type_id = params['id']
	    presale_presale_type = PresalePresaleType.find(:first, :conditions => ["id = ?", presale_presale_type_id])
	    if presale_presale_type
			@presale_comment = PresaleComment.new
			@presale_comment.presale_presale_type = presale_presale_type
	    end 
	end

end
