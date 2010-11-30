require 'rubygems'
#require 'natural_sort'

class Project < ActiveRecord::Base

  belongs_to  :project
  belongs_to  :supervisor,  :class_name=>"Person"
  has_many    :projects,    :order=>'name', :dependent=>:destroy
  has_many    :requests,    :dependent=>:nullify
  has_many    :statuses,    :dependent => :destroy, :order=>"created_at desc"
  has_many    :actions,     :dependent => :destroy, :order=>"progress"
  has_many    :current_actions, :class_name=>'Action', :conditions=>"progress in('open','in_progress')"
  has_many    :amendments,  :dependent => :destroy, :order=>"done, id"
  has_many    :milestones,  :dependent => :destroy
  has_many    :notes,       :dependent => :destroy
  has_many    :project_people
  has_many    :responsibles, :through=>:project_people

  def visible_actions(user_id)
    Action.find(:all, :conditions=>["project_id=? and (person_id=? or (person_id!=? and private=0))", self.id, user_id, user_id], :order=>"progress, project_id, id")
  end

  def visible_notes(user_id)
    Note.find(:all, :conditions=>["project_id=? and (person_id=? or (person_id!=? and private=0))", self.id, user_id, user_id], :order=>"id desc")
  end

  def icon_status
    case last_status
      when 0; ""
      when 1; "<img src='/images/green.gif' align='left'>"
      when 2; "<img src='/images/amber.gif' align='left'>"
      when 3; "<img src='/images/red.gif' align='left'>"
    end
  end

  def has_status
    s = Status.find(:first, :conditions=>["project_id=?", self.id], :order=>"created_at desc")
    s != [] and s!=nil
  end

  def has_requests
    self.requests.size > 0
  end

  def is_ended
    self.requests.each { |r|
      return false if r.status != 'cancelled' and r.resolution !='ended'
      }
    return true
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

  # stop before the global project name ("RDR > Solution" and not "Suite 7.3 > RDR > Solution")
  def full_wp_name
    rv = self.name
    return self.project.full_wp_name + " > " + rv if self.project and self.project.project
    rv
  end

  # return true if the project or subprojects request is assigned to one of the users in the array
  def has_responsible(user_arr)
    user_arr.each { |id|
      return true if ProjectPerson.find_by_project_id_and_person_id(self.id, id)
      self.projects.each { |p|
        return true if p.has_responsible(user_arr)
        }
      }

    #self.requests.each { |r|
    #  next if not r.resp or r.status == "cancelled" or r.resolution =='ended' or r.resolution =='aborted'
    #  return true if user_arr.include?(r.resp.id)
    #  }
    #self.projects.each { |p|
    #  return true if p.has_responsible(user_arr)
    #  }

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
      return true if s.last_change =~ /#{text}/i
      return true if s.actions =~ /#{text}/i
      return true if s.operational_alert =~ /#{text}/i
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

  def move_milestones_to_project(p)
    p.milestones.each { |m|
      m.destroy if m.status == -1
      }
    self.milestones.each { |m|
      m.project_id = p.id
      m.save
      }
  end

  def move_amendments_to_project(p)
    self.amendments.each { |a|
      a.project_id = p.id
      a.save
      }
  end

  def move_notes_to_project(p)
    self.notes.each { |a|
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

  def create_milestones
    ['M1-M3', 'M3-M5', 'M5-M10', 'Post-M10', 'Maintenance'].each {|m| create_milestone(m)}
  end

  def create_milestone(m)
    case m
      when 'M1-M3'
        rv = self.requests_string(m)
        milestones.create(:project_id=>self.id, :name=>'m3', :comments=>rv[0], :status=>(rv[1] == 0 ? -1 : 0)) if not find_milestone_by_name('m3')
      when 'M3-M5'
        rv = self.requests_string(m)
        milestones.create(:project_id=>self.id, :name=>'QG BRD', :comments=>rv[0], :status=>(rv[1] == 0 ? -1 : 0)) if not find_milestone_by_name('QG BRD')
        milestones.create(:project_id=>self.id, :name=>'QG ARD', :comments=>'No request', :status=>-1) if not find_milestone_by_name('QG ARD')
        milestones.create(:project_id=>self.id, :name=>'m5', :comments=>rv[0], :status=>(rv[1] == 0 ? -1 : 0)) if not find_milestone_by_name('m5')   and not find_milestone_by_name('m5/m7')
      when 'M5-M10'
        rv = self.requests_string(m)
        milestones.create(:project_id=>self.id, :name=>'m7', :comments=>rv[0], :status=>(rv[1] == 0 ? -1 : 0)) if not find_milestone_by_name('m7')   and not find_milestone_by_name('m5/m7')
        milestones.create(:project_id=>self.id, :name=>'m9', :comments=>rv[0], :status=>(rv[1] == 0 ? -1 : 0)) if not find_milestone_by_name('m9')   and not find_milestone_by_name('m9/m10')
        milestones.create(:project_id=>self.id, :name=>'m10', :comments=>rv[0], :status=>(rv[1] == 0 ? -1 : 0)) if not find_milestone_by_name('m10') and not find_milestone_by_name('m9/m10')
      when 'Post-M10'
        rv = self.requests_string(m)
        milestones.create(:project_id=>self.id, :name=>'QG TD', :comments=>rv[0], :status=>(rv[1] == 0 ? -1 : 0)) if not find_milestone_by_name('QG TD')
        milestones.create(:project_id=>self.id, :name=>'m10a', :comments=> rv[0], :status=>(rv[1] == 0 ? -1 : 0)) if not find_milestone_by_name('m10a') and not find_milestone_by_name('m9/m10')
        milestones.create(:project_id=>self.id, :name=>'QG MIP', :comments=>rv[0], :status=>(rv[1] == 0 ? -1 : 0)) if not find_milestone_by_name('QG MIP')
        milestones.create(:project_id=>self.id, :name=>'m11', :comments=> rv[0], :status=>(rv[1] == 0 ? -1 : 0)) if not find_milestone_by_name('m11')
        milestones.create(:project_id=>self.id, :name=>'m12', :comments=> rv[0], :status=>(rv[1] == 0 ? -1 : 0)) if not find_milestone_by_name('m12') and not find_milestone_by_name('m12/m13')
        milestones.create(:project_id=>self.id, :name=>'m13', :comments=> rv[0], :status=>(rv[1] == 0 ? -1 : 0)) if not find_milestone_by_name('m13') and not find_milestone_by_name('m12/m13')
        milestones.create(:project_id=>self.id, :name=>'m14', :comments=> rv[0], :status=>(rv[1] == 0 ? -1 : 0)) if not find_milestone_by_name('m14')
      when 'Maintenance'
        rv = self.requests_string(m)
        milestones.create(:project_id=>self.id, :name=>'maint.', :comments=>rv[0], :status=>(rv[1] == 0 ? -1 : 0)) if not find_milestone_by_name('maint.')
    end
  end

  def requests_string(m)
    rv = ""
    nb = 0
    self.requests.select { |r|
      next if (r.milestone!='N/A' and r.milestone != m) or r.status=='cancelled' or r.status=='to be validated'
      case r.work_package
        when 'WP1.1 - Quality Control'
          nb += 1 and rv += "Control\n"           if m != 'Maintenance'
        when 'WP1.2 - Quality Assurance'
          nb += 1 and rv += "Assurance\n"         if m != 'Maintenance'
        when 'WP2 - Quality for Maintenance'
          nb += 1 and rv += "Maintenance\n"       if m == 'Maintenance'
        when 'WP3 - Modeling'
          nb += 1 and rv += "Modeling\n"          if m == 'M3-M5'
        when 'WP4.1 - Surveillance Audit'
          nb += 1 and rv += "Audit (TBC)\n"       if m == 'M3-M5'
        when 'WP4.2 - Surveillance Root cause'
          nb += 1 and rv += "Root Cause (TBC)\n"  if m == 'M3-M5'
        when 'WP5 - Change Accompaniment'
          nb += 1 and rv += "Change (TBC)\n"      if m == 'M3-M5'
        when 'WP6.1 - Coaching PP'
          nb += 1 and rv += "Coaching PP\n"       if m == 'M1-M3'
        when 'WP6.2 - Coaching BRD'
          nb += 1 and rv += "Coaching BRD\n"      if m == 'M3-M5'
        when 'WP6.3 - Coaching V&V'
          nb += 1 and rv += "Coaching V&V\n"      if m == 'M5-M10'
        when 'WP6.4 - Coaching ConfMgt'
          nb += 1 and rv += "Coaching ConfMgt\n"  if m == 'M1-M3'
        when 'WP6.5 - Coaching Maintenance'
          nb += 1 and rv += "Coaching Maint.\n"   if m == 'Maintenance'
        else
          rv += "unknown workpackage: #{r.work_package}"
      end
      }
    rv = "No request" if rv == ""
    [rv,nb]
  end

  def find_milestone_by_name(name)
    self.milestones.each { |m|
      return m if m.name == name
      }
    nil
  end

  def get_cell_style_for_milestone(m)
    return {} if not m
    case m.status
      when -1
        {'ss:StyleID'=>'s76'}
      when 0
        {'ss:StyleID'=>'s81'}
      when 1
        {'ss:StyleID'=>'s82'}
      when 2
        {'ss:StyleID'=>'s83'}
      when 3
        {'ss:StyleID'=>'s84'}
      else
        {}
    end
  end

  def get_milestone_status(name)
    m = find_milestone_by_name(name)
    if m
      status = m.comments.split("\n").join("\r\n")
      status += "\r\n" + m.date.to_s if m.date
    else
      status = ''
    end
    style  = get_cell_style_for_milestone(m)
    [status,style]
  end

  def sorted_milestones
    #NaturalSort::naturalsort milestones
    milestones.sort_by { |m| milestone_order(m.name)}
  end

  def milestone_order(name)
    case name
    when 'm3';      1
    when 'QG BRD';  2
    when 'QG ARD';  3
    when 'm5';      4
    when 'm5/m7';   5
    when 'm7';      6
    when 'm9';      7
    when 'm9/m10';  8
    when 'm10';     9
    when 'QG TD';   10
    when 'm10a';    11
    when 'QG MIP';  12
    when 'm11';     13
    when 'm12';     14
    when 'm12/m13'; 15
    when 'm13';     16
    when 'm14';     17
    when 'maint.';  18
    else;           0
    end
  end

  # give a list of corresponding requests PM
  def request_pm
    rv = []
    requests.each { |r|
      rv << r.pm if not rv.include?(r.pm)
      }
    rv
  end

  # give a list of corresponding requests QR
  def assignees
    rv = []
    requests.each { |r|
      if r.assigned_to != ''
        person = Person.find_by_rmt_user(r.assigned_to)
      else
        person = nil
      end
      name = person ? person.name : r.assigned_to
      name += " (#{r.work_package})"
      rv << name if not rv.include?(name)
      }
    rv
  end

  # set last status explanation_diff and last_change_diff
  def calculate_diffs
    s = self.statuses
    return if s.size < 2
    s[0].explanation_diffs = Differ.diff(s[0].explanation,s[1].explanation).to_s.split("\n").join("<br/>") if s[0].explanation and s[1].explanation
    s[0].last_change_diffs = Differ.diff(s[0].last_change,s[1].last_change).to_s.split("\n").join("<br/>") if s[0].last_change and s[1].last_change
    s[0].save
  end

  def add_responsible(user)
    self.responsibles << user if not self.responsibles.exists?(user)
  end

  def add_responsible_from_rmt_user(rmt_user)
    return if rmt_user.empty?
    u = Person.find_by_rmt_user(rmt_user)
    self.add_responsible(u) if u
  end

private

  def days_ago(date_time)
    return "" if date_time == nil
    Date.today() - Date.parse(date_time.to_s)
  end
end

