require 'rubygems'
#require 'natural_sort'

class Project < ActiveRecord::Base

  FullGPP     = 0
  LightGPP    = 1
  Maintenance = 2
  LBIPGx      = 3
  LBIPgx      = 4
  LBIPpgx     = 5
  Suite       = 6

  belongs_to  :project
  belongs_to  :supervisor,  :class_name=>"Person"
  belongs_to  :lifecycle_object, :class_name=>"Lifecycle", :foreign_key=>"lifecycle_id"
  belongs_to  :qr_qwr, :class_name=>"Person"
  belongs_to  :suite_tag
  has_many    :projects,    :order=>'name', :dependent=>:nullify
  has_many    :requests,    :dependent=>:nullify
  has_many    :statuses,    :dependent => :destroy, :order=>"created_at desc"
  has_many    :actions,     :dependent => :destroy, :order=>"progress"
  has_many    :current_actions, :class_name=>'Action', :conditions=>"progress in('open','in_progress')"
  has_many    :amendments,  :dependent => :destroy, :order=>"done, id"
  has_many    :current_amendments, :class_name=>'Amendment', :conditions=>"done = 0"
  has_many    :milestones,  :dependent => :destroy
  has_many    :notes,       :dependent => :destroy
  has_many    :project_people
  has_many    :responsibles, :through=>:project_people
  has_many    :risks,       :order=>'id', :dependent=>:destroy
  has_many    :quality_risks,  :class_name=>"Risk", :foreign_key=>"project_id", :order=>'id', :dependent=>:destroy, :conditions=>"is_quality=1"
  has_many    :open_quality_risks,  :class_name=>"Risk", :foreign_key=>"project_id", :order=>'id', :dependent=>:destroy, :conditions=>"is_quality=1 and probability>0"
  has_many    :checklist_items, :through=>:milestones
  has_many    :project_check_items, :class_name=>"ChecklistItem"
  has_many    :project_check_root_items, :conditions=>"parent_id=0", :class_name=>"ChecklistItem"
  has_many    :spiders,      :dependent => :destroy
  has_many    :wl_lines, :dependent => :nullify

  def planning
    planning = Planning.find(:first, :conditions=>["project_id=#{self.id}"])
    return planning
  end
  def number_lines_per_person(person_id)
    return WlLine.find(:all, :conditions=>["project_id=#{self.id} and person_id=#{person_id}"]).size
  end
  def project_check_items_numbers
    cs = self.project_check_items.select{|c| c.ctemplate.ctype!="folder"}
    ns = cs.select{|c| c.status > 0}
    [ns.size, cs.size]
  end

  def transverse_checklists
    self.project_check_items.select{|c| c.ctemplate.ctype!="folder" and c.ctemplate.is_transverse==1 }
  end

  def visible_actions(user_id)
    if Person.find(user_id).is_supervisor == 0
      Action.find(:all, :conditions=>["project_id=?", self.id], :order=>"progress, project_id, id")
    else
      Action.find(:all, :conditions=>["project_id=? and (person_id=? or (person_id!=? and private=0))", self.id, user_id, user_id], :order=>"progress, project_id, id")
    end
  end

  # return [[the 2 milestones that has been taken for the length calcul],
  # the actual length, the initial planned length]
  def length
    milestones = self.sorted_milestones
    # find the first milestone to have a date
    first = nil
    milestones.each_with_index { |m,i|
      first = m and break if m.actual_milestone_date or m.milestone_date
      }
    # find the last milestone to have a date
    last = nil
    milestones.reverse.each_with_index { |m,i|
      last = m and break if m.actual_milestone_date or m.milestone_date
      }
    l = -1
    l = last.actual_milestone_date-first.actual_milestone_date if first and
       first.actual_milestone_date and last and last.actual_milestone_date
    pl = -1
    pl = last.milestone_date-first.milestone_date if first and
       first.milestone_date and last and last.milestone_date
    [[first,last],l,pl]
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
    s = Status.new({:status=>0}) if s == [] or s == nil
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
  def has_responsible(user_id_arr)
    user_id_arr.each { |id|
      return true if ProjectPerson.find_by_project_id_and_person_id(self.id, id)
      self.projects.each { |p|
        return true if p.has_responsible(user_id_arr)
        }
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

  def has_circular_reference?(trace=[])
    trace << self
    self.projects.each { |p|
      return true if trace.include?(p)
      return true if p.has_circular_reference?(trace)
      }
    false
  end

  def project_requests_progress_status()
    status = self.requests_progress_status
    self.projects.each { |p|
      s = p.project_requests_progress_status()
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

  def suite_tag_name
    s = self.suite_tag
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
      m.destroy if m.status == -1 and m.checklist_items.size == 0
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
    move_milestones_to_project(p) # checklist_items will follow
    move_amendments_to_project(p)
    move_notes_to_project(p)
    move_statuses_to_project(p)
    move_risks_to_project(p)
  end

  def open_requests
    self.requests.select { |r| r.status != 'cancelled' and r.status != 'removed' and r.resolution != "ended" and r.resolution != 'aborted'}
    # good to keep "to be validated" requests
  end

  def active_requests
    self.requests.select { |r| r.status == "assigned" and r.resolution != "ended" and r.resolution != "aborted"}
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
    #LifecycleMilestone.find(:all, :conditions => ["lifecycle_id = ?",self.lifecycle_object.id]).each {|m| create_milestone(m.milestone_name.title)}
    case self.lifecycle_object.name
        when "Full GPP"
          ['M1', 'M3', 'QG BRD', 'QG ARD', 'M5', 'M7', 'M9', 'M10', 'QG TD', 'M10a', 'QG MIP', 'M11', 'M12', 'M13', 'M14'].each {|m| create_milestone(m)}
        when "Light GPP"
          ['M1', 'M3', 'QG BRD', 'QG ARD', 'M5/M7', 'M9/M10', 'QG TD', 'QG MIP', 'M11', 'M12/M13', 'M14'].each {|m| create_milestone(m)}
        when "Maintenance"
          ['CCB', 'QG TD M', 'MIPM'].each {|m| create_milestone(m)}
        when "LBIP Gx"
          ['G0', 'G2', 'G3', 'G4', 'QG BRD', 'G5', 'G6', 'G7', 'G8', 'G9'].each {|m| create_milestone(m)}
        when "LBIP gx"
          ['g0', 'g2', 'g3', 'g4', 'g5', 'g6', 'g7', 'g8', 'g9'].each {|m| create_milestone(m)}
        when "LBIP pgx"
          ['pg0', 'pg2', 'pg3', 'pg4', 'pg5', 'pg6', 'pg7', 'pg8', 'pg9'].each {|m| create_milestone(m)}
        when "Suite"
          ['sM1', 'sM3', 'sM5', 'sM13', 'sM14'].each {|m| create_milestone(m)}
        end
  end

  def set_lifecycle_old_param
    case self.lifecycle_object.name
         when "Full GPP"
           self.lifecycle = FullGPP
         when "Light GPP"
           self.lifecycle = LightGPP
         when "Maintenance"
           self.lifecycle = Maintenance
         when "LBIP Gx"
           self.lifecycle = LBIPGx
         when "LBIP gx"
           self.lifecycle = LBIPgx
         when "LBIP pgx"
           self.lifecycle = LBIPpgx
         when "Suite"
           self.lifecycle = Suite
    end
  end

  def check
    self.check_milestones
  end

  def check_milestones
    self.create_milestones
    self.milestones.each(&:check)
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
        # SAME
        when 'WP1.1 - Quality Control'
          nb += 1 and rv += "Control\n"   if m != 'Maintenance'
        # SAME
        when 'WP1.2 - Quality Assurance'
          nb += 1 and rv += "Assurance\n"   if m != 'Maintenance'
        # NEW
        when 'WP1.3 - BAT'
          nb += 1 and rv += "Control BAT\n"   if m != 'Maintenance'
        # OLD
        when 'WP1.3 - Quality Control + BAT'
          nb += 1 and rv += "Control BAT\n"   if m != 'Maintenance'
        # NEW
        when 'WP1.4 - Agility'
          nb += 1 and rv += "Agility\n"   if m != 'Maintenance'
        # OLD
        when 'WP1.4 - Quality Assurance + BAT'
          nb += 1 and rv += "Assurance BAT\n"   if m != 'Maintenance'
        # NEW
        when 'WP1.5 - SQR'
          nb += 1 and rv += "SQR\n"   if m != 'Maintenance'

        # NEW
        when 'WP1.6.2 - QWR Project Setting-up'
          nb += 1 and rv += "Project Setting-up\n"  if m != 'Maintenance'
        # NEW
        when 'WP1.6.6 – QWR QG BRD'
          nb += 1 and rv += "QG BRD\n"    if m != 'Maintenance'
        # NEW
        when 'WP1.6.7 – QWR QG TD'
          nb += 1 and rv += "QG TD\n"   if m != 'Maintenance'
        # NEW
        when 'WP1.6.8 – QWR Lessons Learnt'
          nb += 1 and rv += "Project Lessons Learnt\n"    if m != 'Maintenance'

        # SAME
        when 'WP2 - Quality for Maintenance'
          nb += 1 and rv += "Maintenance\n"       if m == 'Maintenance'

        # SAME
        when 'WP3.0 - Old Modeling'
          nb += 1 and rv += "Old Modeling\n"        if m == 'M5'
        # SAME
        when 'WP3.1 - Modeling Support'
          nb += 1 and rv += "Modeling 1\n"          if m == 'M5'
        # SAME
        when 'WP3.2 - Modeling Conception and Production'
          nb += 1 and rv += "Modeling 2\n"          if m == 'M5'
        # NEW
        when 'WP3.2.1 - Business Process Layout'
          nb += 1 and rv += "Modeling Business Process Layout\n"    if m == 'M5'
        # NEW
        when 'WP3.2.2 - Functional Layout (Use Cases)'
          nb += 1 and rv += "Modeling Use Cases\n"   if m == 'M5'
        # NEW
        when 'WP3.2.3 - Information Layout (Data Model)'
          nb += 1 and rv += "Modeling Data Model\n"   if m == 'M5'
        # SAME
        when 'WP3.3 - Modeling BAT specific Control'
          nb += 1 and rv += "Modeling 3\n"    if m == 'M5'
        # NEW
        when 'WP3.4 - Modeling BAT specific Production'
          nb += 1 and rv += "Modeling 4\n"    if m == 'M5'

        # SAME
        when 'WP4.1 - Surveillance Audit'
          nb += 1 and rv += "Audit\n"       if m == 'M3'
        # SAME
        when 'WP4.2 - Surveillance Root cause'
          nb += 1 and rv += "Root Cause\n"  if m == 'M3'
        # NEW
        when 'WP4.3 - Actions Implementation & Control'
          nb += 1 and rv += "Surveillance - Actions Implementation & Control\n"          if m == 'M5'

        # SAME
        when 'WP5 - Change Accompaniment'
          nb += 1 and rv += "Change\n"    if m == 'M3'
        # NEW
        when 'WP5.1 - Change: Diagnosis & Action Plan'
          nb += 1 and rv += "Change - Diagnosis\\n"   if m == 'M3'
        # NEW
        when 'WP5.2 – Change : Implementation Support & Follow-up'
          nb += 1 and rv += "Change - Actions Implementation & Control\n"   if m == 'M5'

        # SAME
        when 'WP6.1 - Coaching PP'
          nb += 1 and rv += "Coaching PP\n"       if m == 'M3'
        # SAME
        when 'WP6.2 - Coaching BRD'
          nb += 1 and rv += "Coaching BRD\n"      if m == 'M5'
        # SAME
        when 'WP6.3 - Coaching V&V'
          nb += 1 and rv += "Coaching V&V\n"      if m == 'M11'
        # SAME
        when 'WP6.4 - Coaching ConfMgt'
          nb += 1 and rv += "Coaching ConfMgt\n"  if m == 'M3'
        # SAME
        when 'WP6.5 - Coaching Maintenance'
          nb += 1 and rv += "Coaching Maint.\n"   if m == 'Maintenance'
        # NEW
        when 'WP6.6 – Coaching HLR'
          nb += 1 and rv += "Coaching HLR\n"          if m == 'M5'
        # NEW
        when 'WP6.7 – Coaching Business Process'
          nb += 1 and rv += "Coaching Business Process\n"          if m == 'M5'
        # NEW
        when 'WP6.8 – Coaching Use Case'
          nb += 1 and rv += "Coaching Use Case\n"          if m == 'M5'
        # NEW
        when 'WP6.9 – Coaching Data Model'
          nb += 1 and rv += "Coaching Data Model\n"          if m == 'M5'

        # NEW
        when 'WP7.2.1 - Expertise Activities for Project: Requirements Management'
          nb += 1 and rv += "Expert Req Management\n"          if m == 'M3'
        # NEW
        when 'WP7.2.2 - Expertise Activities for Project: Risks Management'
          nb += 1 and rv += "Expert Risks Management\n"          if m == 'M3'
        # NEW
        when 'WP7.2.3 - Expertise Activities for Project: Test Management'
          nb += 1 and rv += "Expert Test Management\n"          if m == 'M5'
        # NEW
        when 'WP7.2.4 - Expertise Activities for Project: Change Management'
          nb += 1 and rv += "Expert Change Management\n"          if m == 'M5'
        # NEW
        when 'WP7.2.5 - Expertise Activities for Project: Lessons Learnt'
          nb += 1 and rv += "Expert Lessons Learnt\n"          if m == 'M5'
        # NEW
        when 'WP7.2.6 - Expertise Activities for Project: Configuration Management'
          nb += 1 and rv += "Expert Conf Management\n"          if m == 'M3'

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

  # names is a array of names mutually exclusive (if we found M5 we should not be able to found a G5)
  # ex: ['M5','G5','g5','pg5', 'CCB']
  def get_milestone_status(names)
    status, style = '',{}
    for name in names
      m = find_milestone_by_name(name)
      if m
        status += name + ': '+m.comments.split("\n").join("\r\n")
        status += "\r\n" + m.date.to_s if m.date
        status += "\r\n"
        style  = get_cell_style_for_milestone(m)
      end
    end
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

  def get_next_milestone_done
    # Current milestone
    i = get_current_milestone_index
    # Not managed
    return ["", "", {}] if not i or i >= milestones.size-1
    # Next milestone
    # Get the next milestone which is "not done yet"
    for y in i..milestones.size-1
      if sorted_milestones[y].done == 0
        return [sorted_milestones[y].name] + get_milestone_status(sorted_milestones[y].name)
      end
    end 
    # Not managed
    return ["", "", {}]
  end

  def sorted_milestones
    #NaturalSort::naturalsort milestones
    milestones.sort_by { |m| [milestone_order(m.name), (m.date ? m.date : Date.today())]}
  end

  def milestone_order(name)
    case name
    when 'M1';      3
    when 'M3';      4
    when 'QG BRD';  5
    when 'QG ARD';  6
    when 'M5';      7
    when 'M5/M7';   8
    when 'M7';      9
    when 'M9';      10
    when 'M9/M10';  11
    when 'M10';     12
    when 'CCB';     12
    when 'QG TD';   13
    when 'QG TD M';   13
    when 'MIPM';    14
    when 'M10a';    14
    when 'QG MIP';  15
    when 'M11';     16
    when 'M12';     17
    when 'M12/M13'; 18
    when 'M13';     19
    when 'M14';     20
    when 'G0';  1
    when 'G2';  2
    when 'G3';  3
    when 'G4';  4
    when 'G5';  6
    when 'G6';  7
    when 'G7';  8
    when 'G8';  9
    when 'G9';  10
    when 'g0';  1
    when 'g2';  2
    when 'g3';  3
    when 'g4';  4
    when 'g5';  6
    when 'g6';  7
    when 'g7';  8
    when 'g8';  9
    when 'g9';  10
    when 'pg0';  1
    when 'pg2';  2
    when 'pg3';  3
    when 'pg4';  4
    when 'pg5';  6
    when 'pg6';  7
    when 'pg7';  8
    when 'pg8';  9
    when 'pg9';  10
    when 'sM1';  3
    when 'sM3';  4
    when 'sM5';  7
    when 'sM13'; 19
    when 'sM14'; 20
    else;        0
    end
  end

  # give a list of corresponding requests PM
  def request_pm
    requests.map{|r| r.pm}.uniq
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
      next if m.done != 0 or (m.milestone_date == nil and m.actual_milestone_date == nil)
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
      next if m.done != 0 or (m.milestone_date == nil and m.actual_milestone_date == nil)
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
    self.risks.each { |r|
      if (r.is_quality == 1)
        rv = 2 if rv < 2 and (r.isMedium? or r.isHigh?)
        rv = 3 if rv < 3 and r.isCritical?
      end
    }
    rv
  end

  def is_consistent_with_risks
    s = self.get_status.status
    return true if s == 0
    return false if s != self.suggested_status
    true
  end

  def self.active_projects_by_workstream(ws_name)
    projects = Project.find(:all, :conditions=>["workstream=?", ws_name])
    projects.select { |p| p.active_requests.size > 0}
  end

  # Calculate the previsional number of QS of the project
  def calcul_qs_previsional
    # Params
    last_milestone_date = nil
    milestones_array = sorted_milestones

    # Get last milestone date
    sorted_milestones.reverse!.each do |m|
      if m.actual_milestone_date
        last_milestone_date = m.actual_milestone_date
        break
      elsif m.milestone_date
        last_milestone_date = m.milestone_date
        break
      end
    end

    # Compare with current date
    today = Date.today
    if ((last_milestone_date) && (last_milestone_date > today))
      nb_qs = 12 * (last_milestone_date.year - today.year) + last_milestone_date.month - today.month
      return nb_qs
    else
      return 0
    end
  end

  # Calculate the previsional number of spiders of the projet
  def calcul_spider_previsional
    spider_counter = 0
    # Get nb of milestones not passed
    sorted_milestones.each do |m|
      m_name = MilestoneName.first(:conditions=>["title = ?",m.name])
      if (m.done == 0) and ((m_name != nil) and (m_name.count_in_spider_prev))
        if m.actual_milestone_date
          # Sub-if because we need to check this independently of the presence of actual milestone date
          if m.actual_milestone_date > DateTime.now.to_date
            spider_counter = spider_counter + 1
          end
        elsif m.milestone_date
          # Sub-if because we need to check this independently of the presence of milestone_date
          if m.milestone_date > DateTime.now.to_date
              spider_counter = spider_counter + 1
          end # End if m.milestone_date > Date.now
        end # End if m.milestone_date
      end # End if (m.done == 0) and ((m_name != nil) and (m_name.count_in_spider_prev))
    end # End sorted_milestones.each

    return spider_counter
  end


# Get the last incrementation date of QS count
def get_last_qs_increment
  last_inc =  HistoryCounter.last(:include => :status, :conditions=>["concerned_status_id IS NOT NULL and statuses.project_id = ?" ,self.id])
  if last_inc
    return last_inc.created_at
  else
    return nil
  end
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
