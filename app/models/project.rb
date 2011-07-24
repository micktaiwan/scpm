require 'rubygems'
#require 'natural_sort'

class Project < ActiveRecord::Base

  FullGPP       = 0
  LightGPP      = 1
  Maintenance   = 2
  LBIP          = 3

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
  has_many    :risks,       :order=>'id', :dependent=>:destroy
  has_many    :quality_risks,  :class_name=>"Risk", :foreign_key=>"project_id", :order=>'id', :dependent=>:destroy, :conditions=>"is_quality=1"

  def visible_actions(user_id)
    if Person.find(user_id).is_supervisor == 0
      Action.find(:all, :conditions=>["project_id=?", self.id], :order=>"progress, project_id, id")
    else
      Action.find(:all, :conditions=>["project_id=? and (person_id=? or (person_id!=? and private=0))", self.id, user_id, user_id], :order=>"progress, project_id, id")
    end
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
      return false if r.status != 'cancelled' and r.status != 'removed' and r.status != 'performed' and r.resolution !='ended' and r.resolution !='aborted'
      }
    return true
  end

  def get_status(before_date=Date.today+1.day)
    s = Status.find(:first, :conditions=>["project_id=? and updated_at <= ?", self.id, before_date], :order=>"updated_at desc")
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

  def move_statuses_to_project(p)
    self.statuses.each { |s|
      s.project_id = p.id
      s.save
      }
    p.update_status
    p.save
    self.update_status
    self.save
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

  def move_risks_to_project(p)
    self.risks.each { |a|
      a.project_id = p.id
      a.save
      }
  end

  def move_all(p)
    move_actions_to_project(p)
    move_milestones_to_project(p)
    move_amendments_to_project(p)
    move_notes_to_project(p)
    move_statuses_to_project(p)
    move_risks_to_project(p)
  end

  def open_requests
    self.requests.select { |r| r.status != 'cancelled' and r.status != 'removed' and r.resolution != "ended" and r.resolution != 'aborted'} # good to keep "to be validated" requests
  end

  def active_requests
    self.requests.select { |r| r.resolution != "ended" and r.resolution != "aborted" and r.status == "assigned"}
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
      #['M1-M3', 'M3-M5', 'M5-M10', 'Post-M10'].each {|m| create_milestone(m)}
      #return
    case self.lifecycle
    when FullGPP
      ['M1', 'M3', 'QG BRD', 'QG ARD', 'M5', 'M7', 'M9', 'M10', 'QG TD', 'M10a', 'QG MIP', 'M11', 'M12', 'M13', 'M14'].each {|m| create_milestone(m)}
    when LightGPP
      ['M1', 'M3', 'QG BRD', 'QG ARD', 'M5/M7', 'M9/M10', 'QG TD', 'QG MIP', 'M11', 'M12/M13', 'M14'].each {|m| create_milestone(m)}
    when Maintenance
      ['CCB', 'QG TD M', 'MIPM'].each {|m| create_milestone(m)}
    when LBIP
      ['G1', 'G2', 'G3', 'G4', 'G5', 'G6', 'G7', 'G8', 'G9'].each {|m| create_milestone(m)}
    end
  end

  def can_create(m)
    rv = case m
      when 'M5/M7'
        find_milestone_by_name('M5') or find_milestone_by_name('M7')
      when 'M5'
        find_milestone_by_name('M5/M7')
      when 'M7'
        find_milestone_by_name('M5/M7')
      when 'M9/M10'
        find_milestone_by_name('M9') or find_milestone_by_name('M10')
      when 'M9'
        find_milestone_by_name('M9/M10')
      when 'M10'
        find_milestone_by_name('M9/M10')
      when 'M12/M13'
        find_milestone_by_name('M12') or find_milestone_by_name('M13')
      when 'M12'
        find_milestone_by_name('M12/M13')
      when 'M13'
        find_milestone_by_name('M12/M13')
    end
    not rv and not find_milestone_by_name(m)
  end

  def create_milestone(m)
    rv = self.requests_string(m)
    milestones.create(:project_id=>self.id, :name=>m, :comments=>rv[0], :status=>(rv[1] == 0 ? -1 : 0)) if can_create(m)
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
          nb += 1 and rv += "Modeling\n"          if m == 'M5'
        when 'WP4.1 - Surveillance Audit'
          nb += 1 and rv += "Audit (TBC)\n"       if m == 'M3'
        when 'WP4.2 - Surveillance Root cause'
          nb += 1 and rv += "Root Cause (TBC)\n"  if m == 'M3'
        when 'WP5 - Change Accompaniment'
          nb += 1 and rv += "Change (TBC)\n"      if m == 'M3'
        when 'WP6.1 - Coaching PP'
          nb += 1 and rv += "Coaching PP\n"       if m == 'M3'
        when 'WP6.2 - Coaching BRD'
          nb += 1 and rv += "Coaching BRD\n"      if m == 'M5'
        when 'WP6.3 - Coaching V&V'
          nb += 1 and rv += "Coaching V&V\n"      if m == 'M12'
        when 'WP6.4 - Coaching ConfMgt'
          nb += 1 and rv += "Coaching ConfMgt\n"  if m == 'M14'
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

  def get_current_milestone_status
    i = get_current_milestone_index
    return ["", "", {}] if not i
    m =  sorted_milestones[i]
    [m.name] + get_milestone_status(m.name)
  end

  def get_last_milestone_status
    i = get_current_milestone_index
    return ["", "", {}] if not i or i == 0
    m =  sorted_milestones[i-1]
    [m.name] + get_milestone_status(m.name)
  end

  def get_next_milestone_status
    i = get_current_milestone_index
    return ["", "", {}] if not i or i >= milestones.size-1
    m =  sorted_milestones[i+1]
    [m.name] + get_milestone_status(m.name)
  end

  def sorted_milestones
    #NaturalSort::naturalsort milestones
    milestones.sort_by { |m| milestone_order(m.name)}
  end

  def milestone_order(name)
    case name
    when 'M1';      0
    when 'M3';      1
    when 'QG BRD';  2
    when 'QG ARD';  3
    when 'M5';      4
    when 'M5/M7';   5
    when 'M7';      6
    when 'M9';      7
    when 'M9/M10';  8
    when 'M10';     9
    when 'CCB';     9
    when 'QG TD';   10
    when 'QG TD M';   10
    when 'MIPM';    11
    when 'M10a';    11
    when 'QG MIP';  12
    when 'M11';     13
    when 'M12';     14
    when 'M12/M13'; 15
    when 'M13';     16
    when 'M14';     17
    when 'Maintenance';  18
    when 'G2';  2
    when 'G3';  3
    when 'G4';  4
    when 'G5';  5
    when 'G6';  6
    when 'G7';  7
    when 'G8';  8
    when 'G9';  9
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
    s[0].last_change_excel = excel(s[0].last_change,s[1].last_change).to_s.split('\r\n').join('&#10;')       if s[0].last_change and s[1].last_change
    s[0].save
  end

  def add_responsible(user)
    self.responsibles << user if not self.responsibles.exists?(user)
  end

  def add_responsible_from_rmt_user(rmt_user)
    return false if rmt_user.empty?
    u = Person.find_by_rmt_user(rmt_user)
    return false if not u
    self.add_responsible(u)
    return true
  end

  def get_current_milestone_index
    rv    = nil
    date  = nil
    sorted_milestones.each_with_index { |m, i|
      next if m.done != 0 or m.status == -1 or (m.milestone_date == nil and m.actual_milestone_date == nil)
      if m.actual_milestone_date and m.actual_milestone_date != ""
        if not date or m.actual_milestone_date < date
          date = m.actual_milestone_date
          rv = i
        end
      elsif m.milestone_date and m.milestone_date != ""
        if not date or m.milestone_date < date
          date = m.milestone_date
          rv = i
        end
      end
      }
    rv
  end

  def next_milestone_date
    date = nil
    self.milestones.each { |m|
      next if m.done != 0 or m.status == -1 or (m.milestone_date == nil and m.actual_milestone_date == nil)
      if m.actual_milestone_date and m.actual_milestone_date != ""
        date = m.actual_milestone_date if not date or m.actual_milestone_date < date
      elsif m.milestone_date and m.milestone_date != ""
        date = m.milestone_date if not date or m.milestone_date < date
      end
      }
    date
  end

  def suggested_status
    rv = 1
    self.quality_risks.each { |r|
      rv = 2 if rv < 2 and r.severity >=6
      rv = 3 if rv < 3 and r.severity >=8
      }
    rv
  end

private

  def excel(a,b)
    Differ.diff(a,b).format_as(DiffExcel)
  end

  def days_ago(date_time)
    return "" if date_time == nil
    Date.today() - Date.parse(date_time.to_s)
  end
end

module DiffExcel
  class << self
    def format(change)
      (change.change? && as_change(change)) ||
      (change.delete? && as_delete(change)) ||
      (change.insert? && as_insert(change)) ||
      ''
    end

  private
    def as_insert(change)
      "<B>#{change.insert}</B>&#10;"
    end

    def as_delete(change)
      ""
    end

    def as_change(change)
      "<B>#{change.insert}</B>&#10;"
    end
  end
end
