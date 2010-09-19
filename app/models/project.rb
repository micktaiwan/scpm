class Project < ActiveRecord::Base

  belongs_to  :project
  belongs_to  :supervisor, :class_name=>"Person"
  has_many    :projects, :order=>'name', :dependent=>:destroy
  has_many    :requests, :dependent=>:nullify
  has_many    :statuses, :dependent => :destroy, :order=>"updated_at desc"
  has_many    :actions, :dependent => :destroy, :order=>"progress"
  has_many    :current_actions, :class_name=>'Action', :conditions=>"progress in('open','in_progress')"

  def icon_status
    case last_status
      when 0; "<img src='/images/unknown.png' align='right'>"
      when 1; "<img src='/images/green.gif' align='left'>"
      when 2; "<img src='/images/amber.gif' align='left'>"
      when 3; "<img src='/images/red.gif' align='left'>"
    end
  end

  def has_status
    Status.find(:first, :conditions=>["project_id=?", self.id], :order=>"created_at desc")
  end

  def get_status
    s = has_status
    s = Status.new({:status=>0, :explanation=>"unknown"}) if not s
    s
  end

  def last_status_date
    #time_ago_in_words(get_status.updated_at)
    days_ago(get_status.updated_at)
  end

  def update_status(s = nil)
    if s
      self.last_status = s
      save
    end
    propagate_status
  end

  # look at sub projects status and calculates its own
  def propagate_status
    if has_status # so if the status was green only because a green sub project (status == nil) the status wont' be updated
      status = self.last_status
    else
      status = 0
    end
    self.projects.each { |p|
      status = p.last_status if status < p.last_status
      }
    self.last_status = status
    save
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
      next if not r.resp
      return true if user_arr.include?(r.resp.id)
      }
    self.projects.each { |p|
      return true if p.has_responsible(user_arr)
      }
    return false
  end

  # recursively get the last status date
  def last_status_date
    status = has_status
    date = nil
    date = status.updated_at if status
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
      status = r.progress_status
      }
    return status
  end

  def text_filter(text)
    return true if self.name =~ /#{text}/i
    return true if self.description =~ /#{text}/i
    self.statuses.each { |s|
      return true if s.explanation =~ /#{text}/i
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

private

  def days_ago(date_time)
    return "" if date_time == nil
    Date.today() - Date.parse(date_time.to_s)
  end
end

