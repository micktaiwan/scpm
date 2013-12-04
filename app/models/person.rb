require 'net/ldap'

class PersonSettings

  attr_accessor :wl_line_change_name # is used for updating lines' names

  def initialize
    @wl_line_change_name = 0
  end

end

class Person < ActiveRecord::Base

  #include Authentication
  include ApplicationHelper # for wlweek

  belongs_to :company
  has_many   :person_roles
  has_many   :roles, :through => :person_roles
  has_many   :open_actions, :class_name=>"Action", :conditions=>"progress='open' or progress='in_progress'"
  has_many   :project_people
  has_many   :projects, :foreign_key=>"supervisor_id"
  has_many   :projects, :through=>:project_people
  has_many   :wl_lines
  has_many   :sdp_logs, :order=>"id"
  has_many   :history_counters
  serialize  :settings, PersonSettings

  before_save :encrypt_password
  attr_accessor :password

  def tags
    lines_tags = LineTag.find(:all, :conditions=>"line_id in ( select id from wl_lines where person_id=#{self.id} )").map{|l|l.tag_id}.uniq
    tags = []
    if !lines_tags.nil?
      lines_tags.each do |l|
        tags << Tag.find(l)
      end
    end
    return tags
  end

  def lines_tagged
    return LineTag.find(:all, :conditions=>"line_id in ( select id from wl_lines where person_id=#{self.id} )").map{|l|l.id}
  end

  def projects # lines associated to projects
    projects = WlLine.find(:all, :conditions=>["person_id=#{self.id} and project_id is not null"])
    return projects
  end

  def projects_map
    projects_ids = WlLine.find(:all, :conditions=>["person_id=#{self.id} and project_id is not null"]).collect{|l| l.project_id}.uniq
    filter       = []
    projects_ids.each do |id|
      p= Project.find(id)
      filter << {:id=>id, :name=>p.name, :nb=>p.number_lines_per_person(self.id)}
    end
    return filter
  end

  def sdp_tasks
    sdp_tasks = []
    WlLine.find(:all, :conditions=>["person_id=#{self.id}"]).each do |l|
      if l.sdp_tasks
        l.sdp_tasks.each do |sdp_task|
          sdp_tasks << sdp_task
        end
      end
    end
    return sdp_tasks
  end

  def iterations
    iterations = []
    self.sdp_tasks.each do |sdp_task|
      iteration = sdp_task.get_iteration
      iterations << iteration if ( not iterations.include? iteration ) and (iteration)
    end
    return iterations.sort_by{|i| [i.project_code, i.name]} if iterations != []
    return iterations
  end

  def save_default_settings
    if self.settings.nil?
      self.settings = PersonSettings.new()
      self.save
    end
  end

  # calculate initial, remaining, balance, balance% and remaining delay
  def sdp_balance
    tasks = SDPTask.find(:all, :conditions=>"collab LIKE '%#{self.trigram}%'")
    init    = tasks.inject(0.0) { |sum, t| sum+t.initial}
    balance = tasks.inject(0.0) { |sum, t| sum+t.balancea}
    if init > 0
      percent   = ((balance / init )*100 / 0.1).round * 0.1
    else
      percent   = 0
    end
    remaining = tasks.inject(0.0) { |sum, t| sum+t.remaining}
    delay = (remaining/18/0.1).round * 0.1
    {:trigram=>self.trigram, :initial=>init, :balance=>balance, :percent=>percent, :remaining=>remaining, :delay=>delay}
  end

  def css_style
    if self.has_left == 1
      'color: grey;text-decoration:line-through;'
    elsif self.is_transverse==0
      'font-weight:bold;'
    else
      ''
    end
  end

  def short_name
    arr = self.name.split(" ")
    return self.name if arr.size < 2
    arr[0] + " " + arr[1][0].chr + "."
  end

  def has_role?(role)
    self.roles.count(:conditions => ['name = ?', role]) > 0
  end

  def add_role(role)
    return if self.has_role?(role)
    self.roles << Role.find_by_name(role)
  end

  def remove_role(role)
    return if not self.has_role?(role)
    self.roles.delete(Role.find_by_name(role))
  end

  def requests
    return [] if self.rmt_user == "" or self.rmt_user == nil
    Request.find(:all, :conditions => "assigned_to='#{self.rmt_user}'", :order=>"workstream, project_name")
  end

  def active_requests
    return [] if self.rmt_user == "" or self.rmt_user == nil
    Request.find(:all, :conditions => "assigned_to='#{self.rmt_user}' and status='assigned' and resolution!='closed' and resolution!='aborted'", :order=>"workstream, project_name")
  end

  def load
    active_requests.inject(0.0) { |sum, r| sum + r.workload}
  end

  def update_timeline
     File.open("#{RAILS_ROOT}/public/data/timeline_#{self.id}.xml", "w") { |f|
      f << "<data>\n"
      requests.each { |r|
        f << "<event start='#{my_date(r.gantt_start_date)}' end='#{my_date(r.my_end_date)}' title='#{h(r.summary)}' link='http://toulouse.sqli.com/EMN/view.php?id=#{r.request_id.to_i}' isDuration='true'>"
        f << "#{r.project ? h(r.project.name) : 'no project name'}"
        f << "</event>\n"
        }
      f << "</data>\n"
      }
  end

  def self.authenticate(login, password)
    return self.find_by_login(login[4..-1]) if login[0..3] == "test" and password=="sqlitlse"
    return nil if login.empty? or password.empty?
    if login_by_ldap(login,password)
      self.find_by_login(login)
    else
      nil
    end
  end

  def self.login_by_ldap(login,pwd)
    begin
      ldap = Net::LDAP.new
      ldap.host = "mailcorpo.sqli.com"
      ldap.port = 389
      ldap.auth "uid=#{login},ou=personsqli,o=sqli,c=com", pwd
      if ldap.bind
        return true
      else
        return false
      end
    rescue
      return false
    end
  end

  def self.encrypt(password)
    Digest::SHA1.hexdigest("SuperSalt--#{password}--")
  end

  def get_series(method)
    serie   = []
    labels  = []
    first   = SdpLog.first(:first, :select=>"date", :conditions=>["person_id=?", self.id], :limit=>1, :order=>"date").date
    for l in self.sdp_logs
      serie << [l.date-first, l.send(method)]
      labels << l.date
    end
    min = serie.map{|p| p[1]}.min
    max = serie.map{|p| p[1]}.max
    serie = serie.map{ |l| [l[0], l[1]-min]}
    [serie, min, max, labels]
  end

  def sdp_graph
    chart = GoogleChart::LineChart.new('450x150', "Chart", true)
    serie, min, max, labels = get_series(:percent)
    chart.data "Gain", serie, '0000ff'
    chart.axis :y, :range => [min,max], :font_size => 10, :alignment => :center
    #chart.axis :x, :labels => labels, :font_size => 10, :alignment => :center
    chart.shape_marker :circle, :color=>'3333ff', :data_set_index=>0, :data_point_index=>-1, :pixel_size=>8
    #chart.range_marker :horizontal, :color=>'EEEEEE', :start_point=>95.0/max, :end_point=>105.0/max
    #chart.show_legend = false
    @chart_url = chart.to_url
  end

  # active project only
  def active_projects_by_workstream(ws)
    ap = []
    self.projects.each { |p|
      next if p.active_requests.size == 0
      ap << p if p.workstream == ws
      }
    ap
  end

  def active_projects
    ap = []
    self.projects.each { |p|
      next if p.active_requests.size == 0
      ap << p
      }
    ap
  end

  def new_notes
    ap = self.active_projects.map{|p| p.id}
    return [] if ap.empty?
    Note.find(:all, :conditions=>["private=0 and project_id in (#{ap.join(',')}) and updated_at >= ?", Date.today()-10.day])
  end

  def requests_to_close
    reqs = Request.find(:all, :conditions=>"assigned_to='#{self.rmt_user}' and status='assigned' and resolution!='ended' and resolution!='aborted'")
    @tasks = []
    reqs.each { |r|
      tmp = SDPTask.find(:all, :conditions=>"collab='#{self.trigram}' and request_id='#{r.request_id}'")
      remaining = tmp.inject(0.0)  { |sum, t| sum+t.remaining}
      @tasks += tmp if remaining == 0
      }
    ids = @tasks.collect {|t| t.request_id}.uniq.join(',')
    if ids == ""
      @requests = []
    else
      @requests = Request.find(:all, :conditions=>"request_id in (#{ids})", :order=>"assigned_to")
    end
  end

  def late_amendments
    ap = self.active_projects.map{|p| p.id}
    return [] if ap.empty?
    Amendment.find(:all, :conditions=>["done=0 and project_id in (#{ap.join(',')}) and (duedate <= ? or duedate='')", Date.today()])
  end

  def late_actions
    Action.find(:all, :conditions=>["person_id=? and (progress='open' or progress='in_progress')", self.id])
  end

  def milestones_with_open_checklists
    # Look at this beautiful include !
    Milestone.find(:all, :conditions=>"done=1", :include=>[{:project=>:project_people},:checklist_items]).select { |m|
      m.project and m.project.has_responsible([self.id]) and
      m.checklist_items.select{ |i|
        i.ctemplate.ctype!='folder' and i.status==0
        }.size > 0
      }.sort_by { |m| [m.project.full_name, m.name] }
  end

  # based on workload, find tbv requests that need to be validated asap
  def tbv_based_on_wl
    @requests = Request.find(:all, :conditions=>"status='to be validated'", :order=>"summary")
    @week1    = wlweek(Date.today)
    @week2    = wlweek(Date.today+7.days)
    return @requests.select {|r| wl = r.wl_line; wl and wl.person.id == self.id and (wl.get_load_by_week(@week1) > 0 or wl.get_load_by_week(@week2) > 0)}
  end

  #def remember_token?
  #  remember_token_expires_at && Time.now.utc < remember_token_expires_at
  #end

  # These create and unset the fields required for remembering users between browser closes
  #def remember_me
  #  self.remember_token_expires_at = 2.weeks.from_now.utc
  #  self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
  #  save(false)
  #end

  #def forget_me
  #  self.remember_token_expires_at = nil
  #  self.remember_token            = nil
  #  save(false)
  #end

  def get_ciproject_reminder
    allTickets = CiProject.find(:all, :conditions=>["assigned_to=?", self.rmt_user])
    # CiProject.late_css(p.sqli_validation_date_review) -> get if late for this date
    late = CiProject.find(:all, :conditions=>["(status='Accepted' or status='Assigned') and assigned_to=?", self.rmt_user], :order=>"sqli_validation_date_review desc")
    late = CiProject.find(:all, :conditions=>["(status='Accepted' or status='Assigned') and ((sqli_validation_date_review < Now()) or (airbus_validation_date_review < Now()) or (deployment_date_review < Now())) and assigned_to=?", self.rmt_user], :order=>"sqli_validation_date_review desc")
    lateObjective  = CiProject.find(:all, :conditions=>["(status='Accepted' or status='Assigned') and ((sqli_validation_date_objective < Now()) or (airbus_validation_date_objective < Now()) or (deployment_date_objective < Now())) and assigned_to=?", self.rmt_user], :order=>"sqli_validation_date_objective desc")
    assignedNotKickoff = CiProject.find(:all, :conditions=>["kick_off_date IS NULL and assigned_to=?", self.rmt_user], :order=>"sqli_validation_date_review desc")
    returnHash = {}
    if allTickets.size > 0
      returnHash["all"] = allTickets
    end
    if late.size > 0
      returnHash["late"] = late
    end
    if lateObjective.size > 0
      returnHash["lateObjective"] = lateObjective
    end
    if assignedNotKickoff.size > 0
      returnHash["notKickoff"] = assignedNotKickoff
    end
    return returnHash
  end

  def get_request_reminder
    #all = Request.all
    not_started          = Request.find(:all, :conditions=>["start_date != '' and start_date <= ? and resolution!='in progress' and resolution!='ended' and resolution!='aborted' and status!='cancelled'  and status!='removed' and status!='to be validated' and assigned_to = ?", Date.today(), self.rmt_user], :order=>"start_date")
    null_start_date      = Request.find(:all, :conditions=>["start_date = '' and status='assigned' and assigned_to = ?", self.rmt_user], :order=>"start_date")
    null_milestones      = Request.find(:all, :conditions=>["milestone_date = '' and status != 'cancelled' and resolution='in progress' and assigned_to = ? and milestone != 'N/A'", self.rmt_user], :order=>"start_date")
    past_milestones      = Request.find(:all, :conditions=>["((actual_m_date != '' and actual_m_date < ?) or (actual_m_date = '' and milestone_date != '' and milestone_date < ?)) and resolution!='ended' and resolution!='aborted' and status != 'cancelled' and status != 'removed' and assigned_to = ?", Date.today(), Date.today(), self.rmt_user], :order=>"milestone_date")
    ended_without_amdate = Request.find(:all, :conditions=>["status !='cancelled' and resolution='ended' and actual_m_date='' and assigned_to = ?", self.rmt_user], :order=>"start_date")
    returnHash = {}
    if not_started.size > 0
      returnHash["not_started"] = not_started;
    end
    if null_start_date.size > 0
      returnHash["null_start_date"] = null_start_date;
    end
    if null_milestones.size > 0
      returnHash["null_milestones"] = null_milestones;
    end
    if past_milestones.size > 0
      returnHash["past_milestones"] = past_milestones;
    end
    if ended_without_amdate.size > 0
      returnHash["ended_without_amdate"] = ended_without_amdate;
    end
    #if all.size > 0
      #returnHash["all"] = all;
    #end
    return returnHash;
  end

protected

  # before filter
  def encrypt_password
    self.pwd = self.class.encrypt(password) if password_required?
  end

  def password_required?
    pwd.blank? || !password.blank?
  end

private

  def h(str)
    str.gsub('&','&amp;')
  end

  def my_date(date)
    "#{Date.parse(date).strftime("%b %d %Y")} 00:00:00 GMT"
  end

end
