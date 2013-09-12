module WorkloadPlanningsHelper

	def get_plannings(projects,wl_weeks)
		rv = []
		test = []
		projects.each do |p|
	    planning = p.planning
	    if planning
	      tasks = planning.tasks
	      if tasks
		      tasks.each do |t|
		        start_week = wlweek(t.start_date)
		        end_week   = wlweek(t.end_date)
		        weeks_task = false
		        weeks_task = true if wl_weeks.first > start_week 
		        wl_weeks.each do |w|
		          weeks_task = true if ( w == start_week and !weeks_task ) 
		          rv << {:task=>t, :week=>weeks_task}
		          weeks_task = false if ( w == end_week and weeks_task )
		        end
		      end
		    end
	    end
	  end
		return rv
	end

end