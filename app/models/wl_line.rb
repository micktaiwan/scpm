class WlLine < ActiveRecord::Base

  has_many   :wl_loads, :dependent => :destroy
  belongs_to :person
  belongs_to :request
  # belongs_to :sdp_task, :class_name=>"SDPTask"
  has_many   :wl_line_task
  belongs_to :project
  belongs_to :parent, :class_name => "WlLine", :foreign_key => "parent_line"
  has_many   :duplicates, :foreign_key => "parent_line", :class_name => "WlLine"

  include ApplicationHelper

  def tags
    line_tags = LineTag.find(:all, :conditions=>["line_id = #{self.id}"]).map{|line_tag| line_tag.tag_id}
    tags = []
    tags = Tag.find(:all, :conditions=>["id in (#{line_tags.join(',')})"]) if line_tags.size > 0
    tags
  end

  def tag_in(tags_ids)
    line_tag = LineTag.find(:all, :conditions=>["line_id = #{self.id}"]).map{|line_tag| line_tag.tag_id}
    return false if ( line_tag.nil? or line_tag.size == 0 ) 
    line_tag.each do |l|
      return true if tags_ids.include?(l.to_s)
    end
    false
  end

  def sdp_tasks
    wl_line_task_ids = WlLineTask.find(:all, :conditions=>["wl_line_id=?", self.id])
    return [] if wl_line_task_ids.size == 0
    SDPTask.find_by_sql("select * from sdp_tasks where sdp_tasks.sdp_id in (#{wl_line_task_ids.map{ |l| l.sdp_task_id}.join(',')})")
  end

  def has_wrong_assignation
    return false if !self.person
    sdp_tasks.each { |t|
      return true if t.collab != self.person.trigram
      }
    false
  end

  def add_sdp_task_by_id(sdp_task_id)
    WlLineTask.create(:wl_line_id=>self.id, :sdp_task_id=>sdp_task_id)
  end

  def delete_sdp(sdp_task_id)
    t = WlLineTask.find(:first, :conditions=>["wl_line_id=#{self.id} and sdp_task_id=#{sdp_task_id}"])
    t.destroy if t
  end

  def sdp_tasks_initial
    t = sdp_tasks
    return 0.0 if t.size == 0
    t.map{|t| t.initial}.inject(:+)
  end

  def sdp_tasks_assigned
    t = sdp_tasks
    return 0.0 if t.size == 0
    t.map{|t| t.assigned}.inject(:+)
  end

  def sdp_tasks_balancei
    t = sdp_tasks
    return 0.0 if t.size == 0
    t.map{|t| t.balancei}.inject(:+)
  end

  def sdp_tasks_remaining
    t = sdp_tasks
    return 0.0 if t.size == 0
    t.map{|t| t.remaining}.inject(:+)
  end

  def sdp_tasks_consumed
    t = sdp_tasks
    return 0.0 if t.size == 0
    t.map{|t| t.consumed}.inject(:+)
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
    l.size > 0 ? l.first : 0
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
  def display_name(options={})
    rv = ""
    rv += "#{self.person_name(options)} " if options[:with_person_name]
    if self.wl_type!=WorkloadsController::WL_LINE_HOLIDAYS and
       (self.wl_type!=WorkloadsController::WL_LINE_EXCEPT or self.project_id) 
      tasks_size = self.sdp_tasks.size
      if options[:with_project_name] and APP_CONFIG['workloads_display_project_name_in_lines']
        rv +=     "[#{self.project_name(options)}"
        rv += " x #{tasks_size}" if tasks_size > 1
        rv += "] " + self.name
      else
        rv += self.name
        rv += " #{self.number} lines" if self.class==VirtualWlLine
        rv += " x #{tasks_size} tasks" if tasks_size > 1
      end
      rv += self.tags.map{|t|"<span class='wl_tag'>#{t.name}</span>"}.join(',') if options[:with_tags_names]
      rv
    else
      rv += self.name
    end
    rv
  end

  def title
    "#{self.person_name} #{self.display_name}"
  end

  def person_name(options={})
    if self.person
      if options[:with_person_url]
        "<a href='/workloads/?person_id=#{self.person.id}'>#{self.person.name}</a>"
      else
        self.person.name
      end
    else
      "#{name} (no person attached)"
    end
  end

  def project_name(options={})
    if defined?(self.projects)
      # this line is a group of line (VirtualWlLine)
      if options[:with_project_url]
        self.projects.map{ |p| "<a href='/project_workloads/?project_ids=#{p.id}'>#{p.name}</a>" }.join(', ')
      else
        self.projects.map{ |p| p.name }.join(', ')
      end
    elsif self.project
      # this line use standard association to project model
      if options[:with_project_url]
        "<a href='/project_workloads/?project_ids=#{self.project.id}'>#{self.project.name}</a>"
      else
        self.project.name
      end
    else
      "no project"
    end
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
