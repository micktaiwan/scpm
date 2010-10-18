class Project < ActiveRecord::Base

  belongs_to  :project
  belongs_to  :supervisor,  :class_name=>"Person"
  has_many    :projects,    :order=>'name', :dependent=>:destroy
  has_many    :requests,    :dependent=>:nullify
  has_many    :statuses,    :dependent => :destroy, :order=>"created_at desc"
  has_many    :actions,     :dependent => :destroy, :order=>"progress"
  has_many    :current_actions, :class_name=>'Action', :conditions=>"progress in('open','in_progress')"
  has_many    :amendments,  :dependent => :destroy, :order=>"done, id"

  def icon_status
    case last_status
      when 0; "<img src='/images/unknown.png' align='right'>"
      when 1; "<img src='/images/green.gif' align='left'>"
      when 2; "<img src='/images/amber.gif' align='left'>"
      when 3; "<img src='/images/red.gif' align='left'>"
    end
  end

  def has_status
    s = Status.find(:first, :conditions=>["project_id=?", self.id], :order=>"created_at desc")
    s != [] and s!=nil
  end

  def get_status
    s = Status.find(:first, :conditions=>["project_id=?", self.id], :order=>"created_at desc")
    s = Status.new({:status=>0, :explanation=>"unknown"}) if s == [] or s == nil
    s
  end
  
  def last_reason
    s = get_status
    s.reason
  end

   def last_operational_alert
    s = get_status
    s.operational_alert
  end

  def last_status_description
    get_status.explanation
  end

  
  def old_status
    s = Status.find(:all, :conditions=>["project_id=?", self.id], :order=>"created_at desc", :limit=>2)
    return 0 if s.size < 2
    return s[1].status
  end

  def update_status(s = nil)
    if s
      self.last_status = s
      st = self.get_status
      st.status = s
      st.save
      save
      # puts "changing #{self.name} to #{s}"
    end
    propagate_status
  end

  # look at sub projects status and calculates its own and propagate it to parents
  def propagate_status
    if has_status # so if the status was green only because a green sub project (status == nil) the status won't be updated
      status = self.get_status.status
    else
      status = 0
    end
    self.projects.each { |p|
      status = p.last_status if status < p.last_status
      }
    self.last_status = status
    save
    #puts "#{self.name} status is now #{status}"
    project.propagate_status if self.project
  end

  def propagate_attributes
    self.projects.each { |p|
      p.supervisor_id = self.supervisor_id
      p.save
      p.propagate_attributes
      }
  end

  def full_name
    rv = self.name
    return self.project.full_name + " > " + rv if self.project
    rv
  end

  # return true if the project or subprojects request is assigned to one of the users in the array
  def has_responsible(user_arr)
    self.requests.each { |r|
      next if not r.resp or r.status == "cancelled"
      return true if user_arr.include?(r.resp.id)
      }
    self.projects.each { |p|
      return true if p.has_responsible(user_arr)
      }
    return false
  end

  # recursively get the last status date
  def last_status_date
    status  = get_status
    date    = nil
    date    = status.updated_at if status
    self.projects.each { |p|
      sub   = p.last_status_date
      date  = sub if sub and (date == nil or sub > date)
      }
    return date
  end

  def project_requests_progress_status_html
    s = self.project_requests_progress_status
    return case s
      when 0: "unknown"
      when 1: "ended"
      when 2: "in_progress"
      when 3: "planned"
      when 4: "not_started"
    end
  end


  def project_requests_progress_status
    status = self.requests_progress_status
    self.projects.each { |p|
      s = p.project_requests_progress_status
      status = s if s > status
      }
    return status
  end

  # get all requests status and summarize
  def requests_progress_status
    status = 0
    self.requests.each { |r|
      status = r.progress_status if r.status!='cancelled' and status < r.progress_status
      }
    return status
  end

  def text_filter(text)
    return true if self.name =~ /#{text}/i
    return true if self.description =~ /#{text}/i
    self.statuses.each { |s|
      return true if s.explanation =~ /#{text}/i
      return true if s.feedback =~ /#{text}/i
      }
    self.requests.each { |s|
      return true if s.summary =~ /#{text}/i
      return true if s.pm =~ /#{text}/i
      }
    return false
  end

  def supervisor_name
    s = self.supervisor
    s ? s.name : ''
  end

  def move_actions_to_project(p)
    self.actions.each { |a|
      a.project_id = p.id
      a.save
      }
  end

  def open_requests
    self.requests.select { |r| r.resolution != "ended"}
  end
  
  def project_name
    return project.project_name if self.project
    self.name
  end

  def supervisor_name
    return self.supervisor.name if self.supervisor
    "?"
  end

  
  def sub_has_supervisor
    return false if self.supervisor_id==nil
    self.projects.each{ |p|
      return false if not p.sub_has_supervisor
      }
    return true
  end
  
private

  def days_ago(date_time)
    return "" if date_time == nil
    Date.today() - Date.parse(date_time.to_s)
  end
end

