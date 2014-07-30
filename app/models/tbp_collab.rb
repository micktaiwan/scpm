class TbpCollab < ActiveRecord::Base

  belongs_to  :person
  has_many    :works, :class_name=>'TbpCollabWork', :foreign_key=>"tbp_collab_id", :primary_key=>"tbp_id"

  def get_works_by_date_and_projects(from, to, project_ids)
    sworks = works.find_all.select { |w| w.date >= from and w.date <= to}
    sworks = sworks.select { |w|
        next false if !w.tbp_project # no project in project table (transverse project as holidays?)
        # raise "no project associated for #{w.tbp_project.name}"
        next false if !w.tbp_project.project # no BAM project associated to TBP project
        project_ids.include?(w.tbp_project.project.id.to_s)
        } if project_ids.size > 0
    sworks
  end

  def get_by_date(from, to=from+5.days, project_ids=[])
    sworks = get_works_by_date_and_projects(from, to, project_ids)
    {:works=> sworks, :value=>sworks.inject(0) { |sum, w| sum += w.workload}}
  end

  # returns projects and loads per week
  # ['ProjectName'=>[1, 0.5, 0, 0, ...], 'PN2'=>[...]]
  def projects_workload(from, to=from+5.days, project_ids=[])
    sworks = get_works_by_date_and_projects(from, to, project_ids)
    # sort by project and then by date
    projects = Hash.new
    sworks.each { |w|
      projects[w.tbp_project_name] = Hash.new if !projects[w.tbp_project_name]
      }
    current = from
    while(current < to) do
      sworks.each { |w|
        projects[w.tbp_project_name][current] = 0 if !projects[w.tbp_project_name][current]
        projects[w.tbp_project_name][current] += w.workload if(w.date >= current and w.date < current + 7.days)
        }
      current = current + 7.days
    end
    projects.each_key { |k|
        projects[k] = projects[k].to_a.sort_by { |e| e[0]}.map{|e| e[1]}
      }
    projects.to_a
  end

end
