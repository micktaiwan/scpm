class Spider < ActiveRecord::Base
  belongs_to    :milestone,  :foreign_key=>"milestone_id"
  belongs_to    :project
  has_many      :spider_values
  has_many      :spider_consolidations
  has_many      :lifecycle_questions, :through=>:spider_values
  has_many      :history_counters

def self.spider_export_by_projects_and_milestones(projects)
# TODO FILTER PROEJCTS

	resultArray = Array.new
	axes 		= PmTypeAxe.get_sorted_axes

	# For Each project
	projects.each do |p|
		# For each milestone
		Milestone.find(:all, :conditions => ["project_id = ?", p.id.to_s]).each do |m|
			# Get last spider consolidated
			lastSpider 	= Spider.last(:conditions => ["milestone_id = ?", m.id], :joins => 'JOIN spider_consolidations ON spiders.id = spider_consolidations.spider_id')
			# Array note
			avgArray 			= Array.new

			# For each axe
			axes.each do |a|
				avg 			= ""
				avgRef			= ""
				# Get conso
				if lastSpider
					spiderConso = SpiderConsolidation.find(:first, :conditions => ["spider_id = ? and pm_type_axe_id = ?", lastSpider.id, a.id])
					if spiderConso
						avg 	= spiderConso.average
						avgRef	= spiderConso.average_ref
					end
				end
				# Add in array
				avgArray 		<< avg
				avgArray		<< avgRef
			# End Axe
			end

			# Create Hash
			lineHash = Hash.new
			lineHash["title"]		= p.name
			lineHash["workpackage"]	= p.project.name
			lineHash["milestone"]	= m.name
			lineHash["values"] 		= avgArray 
			resultArray 			<< lineHash
		# End milestone
		end
	# End project
	end
	return resultArray
end



end
