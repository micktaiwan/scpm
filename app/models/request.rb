class Request < ActiveRecord::Base

  belongs_to :project
  belongs_to :wl_line
  # belongs_to :resp, :class_name=>'Person', :conditions=>"assigned_to='people.rmt_user'"

  include WelcomeHelper
  include ApplicationHelper

  def resp
    Person.find(:first, :conditions=>"rmt_user='#{self.assigned_to}'")
  end

  # TODO: contre-visites

  WP_shortnames = { # TODO: use the new model
  "WP1.1 - Quality Control" 		    => "Control",
  "WP1.2 - Quality Assurance" 		  => "Assurance",
  "WP1.3 - BAT"                     => "BAT",
  "WP2 - Quality for Maintenance" 	=> "Maint.",
  "WP3.0 - Old Modeling"            => "Modeling 0",
  "WP3.1 - Modeling Support"        => "Modeling 1",
  "WP3.2 - Modeling Conception and Production" => "Modeling 2",
  "WP3.3 - Modeling BAT specific Control"      => "Modeling 3",
  "WP3.4 - Modeling BAT specific Production"   => "Modeling 4",
  "WP4 - Surveillance" 				      => "Audit",
  "WP4.1 - Surveillance Audit" 		  => "Audit",
  "WP4.2 - Surveillance Root cause" => "RCA",
  "WP5 - Change Accompaniment" 		  => "Change",
  "WP6.1 - Coaching PP" 			      => "PP",
  "WP6.2 - Coaching BRD" 			      => "BRD",
  "WP6.3 - Coaching V&V"            => "V&V",
  "WP6.4 - Coaching ConfMgt"        => "ConfMgt",
  "WP6.5 - Coaching Maintenance"    => "C. Maint."
  }


  Wp_index = { # TODO: use the new model
  "WP1.1 - Quality Control" 		    => 0,
  "WP1.2 - Quality Assurance" 		  => 4,
  "WP1.3 - Quality Control + BAT"   => 0,
  "WP1.4 - Quality Assurance + BAT" => 4,
  "WP2 - Quality for Maintenance" 	=> 8,
  "WP3.0 - Old Modeling"            => 9,
  "WP3.1 - Modeling Support"        => 9,
  "WP3.2 - Modeling Conception and Production" => 9,
  "WP3.3 - Modeling BAT specific Control"      => 9,
  "WP3.4 - Modeling BAT specific Production"   => 9,
  "WP4 - Surveillance" 				      => 10,
  "WP4.1 - Surveillance Audit" 		  => 10,
  "WP4.2 - Surveillance Root cause" => 10,
  "WP5 - Change Accompaniment" 		  => 11,
  "WP6.1 - Coaching PP" 			      => 12,
  "WP6.2 - Coaching BRD" 			      => 13,
  "WP6.3 - Coaching V&V"            => 14,
  "WP6.4 - Coaching ConfMgt"        => 15,
  "WP6.5 - Coaching Maintenance"    => 16,
  "WP1.1 - Quality ControlCV"       => 17,
  "WP1.2 - Quality AssuranceCV"     => 21
  }

  # with BAT
  Wp_index_RFP2012 = { # TODO: use the new model
  "WP1.1 - Quality Control"         => 0,
  "WP1.2 - Quality Assurance"       => 4,
  "WP1.3 - BAT"                     => 8,
  "WP2 - Quality for Maintenance"   => 12,
  "WP3.0 - Old Modeling"            => 13,
  "WP3.1 - Modeling Support"        => 14,
  "WP3.2 - Modeling Conception and Production" => 15,
  "WP3.3 - Modeling BAT specific Control"      => 16,
  "WP3.4 - Modeling BAT specific Production"   => 17,
  "WP4 - Surveillance"              => 18,
  "WP4.1 - Surveillance Audit"      => 18,
  "WP4.2 - Surveillance Root cause" => 18,
  "WP5 - Change Accompaniment"      => 19,
  "WP6.1 - Coaching PP"             => 20,
  "WP6.2 - Coaching BRD"            => 21,
  "WP6.3 - Coaching V&V"            => 22,
  "WP6.4 - Coaching ConfMgt"        => 23,
  "WP6.5 - Coaching Maintenance"    => 24,
  "WP1.1 - Quality ControlCV"       => 25,
  "WP1.2 - Quality AssuranceCV"     => 29
  }

  Comp_index = {
  "Easy" 		  => 0,
  "Medium" 		=> 1,
  "Difficult" => 2,
  "TBD"       => 0
  }

  Milestone_index = {
  "M1-M3" 		=> 0,
  "M3-M5" 		=> 1,
  "M5-M10" 		=> 2,
  "Post-M10" 	=> 3,
  "N/A" 		  => 0
  }

  # reminder: minus 10% for operational meetings
  LoadsRFP2012 = [
    # WP 1.1
    [2.0, 2.125, 2.625],
    [3.375, 4, 5.5],
    [2.625, 3.5, 5.875],
    [4.0, 4.75, 7.0],
    # WP 1.2
    [3.0, 3.5, 4.0],
    [5.75, 7.375, 9.75],
    [5.5, 6.125, 7.125],
    [5.375, 7.0, 9.25],

    # BAT minus 10% total is [4.75, 6.5, 9.25]
    # WP 1.3 (BAT)
    [0, 0, 0], # no M1-M3
    [2.25, 3.25, 4],
    [0.625, 0.875, 1.375],
    [1.75, 2.5, 3.875],

    # WP 2
    [5.125, 7.75, 11.875],

    # WP 3.0 Old
    [8.5, 16.25, 22.5],
    # WP 3.1
    [8.5, 16.25, 22.5],
    # WP 3.2
    [18.5, 42.75, 58.75],
    # WP 3.3
    [3.625, 6.25, 10],
    # WP 3.4
    [7.625, 14, 19.375],
    # WP 4
    [5.5, 7.625, 12.125],
    # WP 5
    [10.75, 23.125, 42.5],
    # WP 6
    [4.75, 11.25, 20.75],
    [3.375, 10.375, 21.625],
    [2.0, 5.875, 14.375],
    [2.75, 13.5, 31.5],
    [7.875, 11.875, 16.375],
    # WP 1.1 CV
    [0.5, 0.5, 0.625],
    [0.875, 0.875, 1.375],
    [0.375, 0.375, 0.5],
    [1.75, 2.25, 2.75],
    # WP 1.2 CV
    [0.5, 0.5, 0.5],
    [1.75, 2.25, 2.75],
    [1.75, 2.75, 3.625],
    [2.75, 3.625, 4.5]
    ]


  Loads2011 = [
    # WP 1.1
    [2.0, 2.125, 2.625],
    [3.25, 3.875, 5.375],
    [2.625, 3.5, 5.875],
    [4.0, 4.75, 7.0],
    # WP 1.2
    [3.0, 3.5, 4.0],
    [5.5, 7.0, 9.375],
    [5.375, 6.0, 7.0],
    [5.375, 7.0, 9.25],
    # WP 2
    [5.125, 7.75, 11.875],
    # WP 3
    [8.5, 16.25, 22.5],
    # WP 4
    [5.5, 7.625, 12.125],
    # WP 5
    [10.75, 23.125, 42.5],
    # WP 6
    [4.75, 11.25, 20.75],
    [3.375, 10.375, 21.625],
    [2.0, 5.875, 14.375],
    [2.75, 13.5, 31.5],
    [7.875, 11.875, 16.375],
    # WP 1.1 CV
    [0.5, 0.5, 0.625],
    [0.875, 0.875, 1.375],
    [0.375, 0.375, 0.5],
    [1.75, 2.25, 2.75],
    # WP 1.2 CV
    [0.5, 0.5, 0.5],
    [1.75, 2.25, 2.75],
    [1.75, 2.75, 3.625],
    [2.75, 3.625, 4.5]
    ]


  Loads2010 = [
    # WP 1.1
    [2.0, 2.125, 2.625],
    [3.625,4.25,6],
    [2.875,3.875,6.5],
    [4.5,5.25,7.75],
    # WP 1.2
    [3.375,3.875,4.5],
    [6.125,7.75,10.375],
    [6,6.625,7.75],
    [6,7.75,10.25],
    # WP 2
    [5.75,8.625,13.25],
    # WP 3
    [9.5,18,25],
    # WP 4
    [6.125,8.5,13.5],
    # WP 5
    [11.875,25.75,47.25],
    # WP 6
    [5.25,12.5,23],
    [3.75,11.5,24],
    [2.25,6.5,16],
    [3,15,35],
    [8.75,13.25,18.25],
    # WP 1.1 CV
    [0.5,0.5,0.75],
    [1,1,1.5],
    [0.375,0.375,0.5],
    [2,2.5,3],
    # WP 1.2 CV
    [0.5,0.5,0.5],
    [2,2.5,3],
    [2,3,4],
    [3,4,5]]

  RMT_TO_BAM = {
    'M1-M3'=>   ['M3','G2','pg2','g2','sM3'],
    'M3-M5'=>   ['M5', 'M5/M7','G5','pg5','g5','sM5'],
    'M5-M10'=>  ['M9/M10', 'M10','G6','pg6','g6'],
    'Post-M10'=>['M12/M13', 'M13', 'sM13','G9','pg9','g9'],
     }

  PHASE_MILESTONES = {
    'M1-M3'=>   ['M3','G2','pg2','g2','sM3'],
    'M3-M5'=>   ['QG BRD', 'QG ARD', 'M5', 'M5/M7','G3','pg3','g3','G4','pg4','g4','G5','pg5','g5','sM5'],
    'M5-M10'=>  ['M7', 'M9', 'M9/M10', 'M10','G6','pg6','g6'],
    'Post-M10'=>['QG TD', 'M10a', 'M11', 'QG MIP', 'M12', 'M12/M13', 'M13', 'M14','sM13','sM14','G7','pg7','g7','G8','pg8','g8','G9','pg9','g9'],
    'WP2 - Quality for Maintenance' 	=> ['CCB', 'QG TD M', 'MIPM'],
    'WP6.1 - Coaching PP' =>    ['M3', 'G2'],
    'WP6.2 - Coaching BRD' =>   ['M5', 'M5/M7', 'G5'],
    'WP6.3 - Coaching V&V' =>   ['M11', 'G7'],
    'WP6.4 - Coaching ConfMgt' =>     ['M3', 'G2'],
    'WP6.5 - Coaching Maintenance' => ['M13','CCB','MIPM'],
    'WP3.0 - Old Modeling' =>         ['M5', 'M5/M7', 'G5'],
    'WP3.1 - Modeling Support' =>     ['M5', 'M5/M7', 'G5'],
    'WP3.2 - Modeling Conception and Production' => ['M5', 'M5/M7', 'G5'],
    'WP3.3 - Modeling BAT specific Control' =>      ['M5', 'M5/M7', 'G5'],
    'WP3.4 - Modeling BAT specific Production' =>   ['M5', 'M5/M7', 'G5'],
    'WP5 - Change Accompaniment' 		  => ['M11']
    }

  def wp_index(wp, cv)
    rv = Wp_index[wp+(cv=="Yes" ? "CV":"")]
    raise "no workpackage #{wp}" if not rv
    rv
  end

    def wp_index_RFP2012(wp, cv)
    rv = Wp_index_RFP2012[wp+(cv=="Yes" ? "CV":"")]
    raise "no workpackage #{wp}" if not rv
    rv
  end

  def milestone_index(m)
    rv = Milestone_index[m]
    raise "no milestone #{m}" if not rv
    rv
  end
  
  def date
    return Date.parse(self.actual_m_date) if self.actual_m_date and self.actual_m_date!=""
    Date.parse(self.milestone_date) if self.milestone_date and self.milestone_date!=""
    Date.parse("1974-06-16")
  end

  def name # so it is the same as Milestone#name
    self.milestone
  end

  def comp_index(c)
    rv = Comp_index[c]
    raise "no complexity #{c}" if not rv
    rv
  end

  def workload
    return 0 if self.status == "cancelled" or self.status == "feedback" or self.status == "performed" or self.resolution == "ended"
    workload2
  end

  def workload2
    if self.status_new and self.status_new >= Date.parse('2012-01-10')
      return LoadsRFP2012[wp_index_RFP2012(self.work_package, self.contre_visite)+milestone_index(self.milestone)][comp_index(self.complexity)]
    elsif self.sdpiteration == "2011" or self.sdpiteration == "2011-Y2"
      return Loads2011[wp_index(self.work_package, self.contre_visite)+milestone_index(self.milestone)][comp_index(self.complexity)]
    elsif self.sdpiteration == "2010"
      return Loads2010[wp_index(self.work_package, self.contre_visite)+milestone_index(self.milestone)][comp_index(self.complexity)]
    else
      0
    end
  end

  # calculate a start date based on the milestone date
  def gantt_start_date
    if self.start_date == ''
      if self.milestone_date != ''
        return (Time.parse(self.milestone_date) - real_duration.days).strftime("%Y-%m-%d")
      else
        return Date.new.strftime("%Y-%m-%d")
      end
    else
      return self.start_date
    end
  end

  # taking into account the start date and the milestone date
  def real_duration
    faed = foreseen_end_date_arr
    rv = if faed != nil and self.start_date != ''
      days = (Time.parse(faed[0]) - Time.parse(self.start_date)) / 1.days
      minus_week_ends(days)
    else
      gantt_duration
    end
    rv = 1 if rv < 1
    rv
  end

  def minus_week_ends(days)
   (days - ((days/7).to_i)*2).to_i
  end

  def rload
    real = real_duration
    real = 1 if real == 0
    return ((gantt_duration.to_f / real) * 100).to_i
  end

  def gantt_duration
    (self.workload+0.5).to_i
  end

  def foreseen_actual_end_date_arr
    return [self.end_date, "e"] if self.end_date and self.end_date != ''
    return [self.actual_m_date, "a"] if self.actual_m_date and self.actual_m_date != ''
    return nil
  end

  def foreseen_end_date_arr
    faed = foreseen_actual_end_date_arr
    return faed if faed != nil
    return [self.milestone_date, "m"] if self.milestone_date and self.milestone_date != ''
    return nil
  end

  def foreseen_end_date_str
    arr = foreseen_end_date_arr
    return "" if arr == nil
    return arr[0] + " (#{arr[1]})"
  end

  def my_end_date
    f = foreseen_end_date_arr
    return f[0] if f
    return (Date.parse(gantt_start_date) + real_duration).to_s
  end

  def sanitized_status
    sanitize(self.status)
  end

  def sanitized_resolution
    sanitize(self.resolution)
  end

  def workpackage_name
    get_workpackage_name_from_summary(self.summary, self.project_name)
  end

  def brn
    self.summary.split(/\[([^\]]*)\]/)[5]
  end

  def move_to_project(p)
    self.project_id = p.id
    self.save
  end

  def progress_status
    return case self.resolution
      when 'not started'; 4
      when 'planned';     3
      when 'in progress'; 2
      when 'ended';       1
      else;               0
    end
  end

  # options is a hash
  # :trigram is the trigram of the person on which to filter
  #  ex: sdp_tasks({:trigram=>'MFM'})
  def sdp_tasks(options=nil)
    cond = ''
    if options
      cond += " and collab LIKE '%#{options[:trigram]}%'" if options[:trigram] and options[:trigram] != ''
    end
    SDPTask.find(:all, :conditions=>"request_id='#{self.request_id}' #{cond}")
  end

  def sdp_tasks_initial_sum(options=nil)
    sdp_tasks(options).inject(0.0) {|sum,t| sum += t.initial}
  end

  def sdp_tasks_remaining_sum(options=nil)
    sdp_tasks(options).inject(0.0) {|sum,t| sum += t.remaining}
  end

  def sdp_tasks_balancei_sum(options=nil)
    sdp_tasks(options).inject(0.0) {|sum,t| sum += t.balancei}
  end

  def sdp_phase_id
    SdpDB.sdp_phase_id(self.work_package)
  end

  def sdp_proposal_id
    SdpDB.sdp_proposal_id(self.work_package)
  end

  def sdp_domain_id
    SdpDB.sdp_domain_id(self.workstream)
  end

  def sdp_activity_id
    m = (self.milestone=="N/A") ? "All" : self.milestone
    SdpDB.sdp_activity_id([m,self.work_package])
  end

  def sdp_user_id
    p = Person.find_by_rmt_user(self.assigned_to)
    return -1 if not p
    return p.sdp_id
  end

  def shortname
    WP_shortnames[self.work_package]
  end

  def workload_name
    ##{appended_string(project.workstream, 6, "&nbsp;")}
   "<b>#{self.project ? self.project.full_name : "no project"}</b> <u>#{self.shortname}</u> #{self.milestone} (<a title='RMT' href='http://toulouse.sqli.com/EMN/view.php?id=#{self.request_id.to_i}'>##{self.request_id.to_i}</a>)"
  end

  # return the corresponding milestone names for this request
  def milestone_names
    if self.milestone != 'N/A'
      PHASE_MILESTONES[self.milestone]
    else
      PHASE_MILESTONES[self.work_package]
    end
  end

  # return the corresponding project milestones for this request
  def milestones
    names = self.milestone_names
    return [] if !names
    self.project.milestones.select{|m| names.include?(m.name)}
  end

  def deploy_checklists
    for t in ChecklistItemTemplate.find(:all, :conditions=>"is_transverse=0")
      deploy_checklist(t)
    end
  end

  def deploy_checklist(ctemplate)
    self.milestones.select{ |m1| m1.checklist_not_applicable==0 and m1.status==0 and m1.done==0 and ctemplate.milestone_names.map{|mn| mn.title}.include?(m1.name)}.each { |m|
      m.deploy_checklist(ctemplate, self)
      }
  end

  def wl_load_by_year(year)
    # get workload line
    line = WlLine.find_by_request_id(self.request_id)
    return nil if !line
    line.wl_loads.select{|l| l.week.to_s[0..3]==year.to_s}.inject(0) { |sum, load| sum+=load.wlload}
  end

  def bam_milestone
    return nil if self.milestone=='N/A'
    RMT_TO_BAM[self.milestone].each { |m_name|
      m = self.project.find_milestone_by_name(m_name) if self.project
      return m if m
      }
    return nil
  end

private

  def sanitize(name)
    name = name.downcase
    name.gsub!("/","")
    name.gsub!("  ","_")
    name.gsub!(" ","_")
    name.gsub!("-","_")
    name
  end

end

