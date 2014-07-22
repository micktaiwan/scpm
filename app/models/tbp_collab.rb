class TbpCollab < ActiveRecord::Base

  belongs_to  :person
  has_many    :works, :class_name=>'TbpCollabWork', :foreign_key=>"tbp_collab_id", :primary_key=>"tbp_id"

  def get_by_date(from, to=from+5.days, project_ids=[])
    sworks = works.find_all.select { |w| w.date >= from and w.date <= to}
    sworks = sworks.select { |w|
        next false if !w.tbp_project # no project in project table (transverse project as holidays?)
        # raise "no project associated for #{w.tbp_project.name}"
        next false if !w.tbp_project.project # no BAM project associated to TBP project
        project_ids.include?(w.tbp_project.project.id.to_s)
        } if project_ids.size > 0
    sworks.inject(0) { |sum, w| sum += w.workload}
  end

end
