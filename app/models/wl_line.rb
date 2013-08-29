class WlLine < ActiveRecord::Base

  has_many   :wl_loads, :dependent => :destroy
  belongs_to :person
  belongs_to :request
  #belongs_to :sdp_task, :class_name=>"SDPTask"
  belongs_to :project
  belongs_to :parent, :class_name => "WlLine", :foreign_key => "parent_line"
  has_many   :duplicates, :foreign_key => "parent_line", :class_name => "WlLine"

  include ApplicationHelper

  #def sdp_task
  #  SDPTask.find_by_sdp_id(self.sdp_task_id)
  #end

  def sdp_tasks
   wl_line_task_ids = WlLineTask.find(:all, :conditions=>["wl_line_id=?", self.id])
   return [] if wl_line_task_ids.size == 0
   SDPTask.find_by_sql("select * from sdp_tasks where sdp_tasks.sdp_id in (#{wl_line_task_ids.map{ |l| l.sdp_task_id}.join(',')})")
  end

  def load_by_week(week)
    #WlLoad.find(:first, :conditions=>["wl_line_id=? and week=?", self.id, week])
    self.wl_loads.select {|l| l.week==week.to_i}
  end

  def get_load_by_week(week)
    loads = load_by_week(week)
    return 0.0 if loads.size == 0
    loads.map {|l| l.wlload}.inject(:+)
  end

  def get_load_object_by_week(week)
    l = load_by_week(week)
    l ? l : 0
  end

  # sum all loads, past and futur
  def sum
    return 0 if self.wl_loads.size == 0
    self.wl_loads.map {|l| l.wlload}.inject(:+)
  end

  # sum only the futur
  def planned_sum
    return 0 if self.wl_loads.size == 0
    today_week = wlweek(Date.today)
    self.wl_loads.map{|l| l.week < today_week ? 0.0 : l.wlload}.inject(:+)
  end

  def near_workload(time=8.week)
    return 0 if wl_loads.size == 0
    today_week = wlweek(Date.today)
    near_week  = wlweek(Date.today + time)
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
    if defined?(self.projects)
      # this line is a group of line (VirtualWlLine)
      self.projects.map{ |p| "<a href='/project_workloads/?project_ids=#{p.id}'>#{p.name}</a>" }.join(', ')
    elsif self.project
      # this line use standard association to project model
      "<a href='/project_workloads/?project_ids=#{self.project.id}'>#{self.project.name}</a>"
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
  
  def wl_type_by_project
    if self.person.is_virtual==1
      return "virtual"
    else
      return self.wl_type
    end
  end

end
