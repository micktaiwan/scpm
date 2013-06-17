class WlLine < ActiveRecord::Base

  has_many   :wl_loads, :dependent => :destroy
  belongs_to :person
  belongs_to :request
  belongs_to :sdp_task, :class_name=>"SDPTask"
  belongs_to :project
  belongs_to :parent, :class_name => "WlLine", :foreign_key => "parent_line"
  has_many   :duplicates, :foreign_key => "parent_line", :class_name => "WlLine"

  include ApplicationHelper

  def sdp_task
    SDPTask.find_by_sdp_id(self.sdp_task_id)
  end

  def load_by_week(week)
    WlLoad.find(:first, :conditions=>["wl_line_id=? and week=?", self.id, week])
  end

  def get_load_by_week(week)
    l = load_by_week(week)
    l ? l.wlload : 0.0
  end

  def get_load_object_by_week(week)
    l = load_by_week(week)
    l ? l : 0
  end

  def planned_sum
    #wl_loads.inject(0) { |sum, l| sum+l.wlload} # did not take into account the fact that we should not sum the past
    return 0 if wl_loads.size == 0
    today_week            = wlweek(Date.today)
    wl_loads.map{|load| (load.week < today_week ? 0.0 : load.wlload)}.inject(:+)
  end

  def near_workload
    return 0 if wl_loads.size == 0
    today_week            = wlweek(Date.today)
    near_week            = wlweek(Date.today + 8.week)
    wl_loads.map{|load| ( (load.week < today_week or load.week >= near_week)  ? 0.0 : load.wlload)}.inject(:+)
  end

  # task name
  def display_name
    #"<a href='#' title='#{name}'>#{name}</a>"
    name
  end

  def person_name
    if self.person
      "<a href='/workloads/?person_id=#{self.person.id}'>#{self.person.name}</a>"
    else
      "#{name} (no person attached)"
    end
  end

  def project_name
    if self.project
      self.project.name
    else
      "no project"
    end
  end

  def title
    "#{self.person_name} #{self.display_name}"
  end

  def request
    Request.find(:first, :conditions=>["request_id=?",filled_number(self.request_id,7)])
  end

  # get milestones for request by week
  def milestones(w)
    return [] if (!request or !request.project) and (!project)
    str = w.to_s
    year = str[0..3].to_i
    week = str[4..5].to_i
    week_start  = Date.commercial(year, week, 1)
    week_end    = Date.commercial(year, week, 7)
    rv = []
    r = request
    p = self.project

    if r && !p
      r.project.milestones.each { |m|
        date = m.date
        rv << m if date and date >= week_start and date <= week_end
      }
    elsif p
      p.milestones.each { |m|
        date = m.date
        rv << m if date and date >= week_start and date <= week_end
      }
    end

    rv
  end

end

