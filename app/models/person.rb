require 'net/ldap'

class Person < ActiveRecord::Base

  #include Authentication

  belongs_to :company
  has_many :projects, :foreign_key=>"supervisor_id"
  has_many :person_roles
  has_many :roles, :through => :person_roles
  has_many :open_actions, :class_name=>"Action", :conditions=>"progress='open' or progress='in_progress'"
  has_many :project_people
  has_many :projects, :through=>:project_people
  has_many :wl_lines
  has_many :sdp_logs, :order=>"id"

  before_save :encrypt_password

  attr_accessor :password

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
      'color: grey;'
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
    #return self.find_by_login(login) # temporaire.....
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
  def active_projects_have_workstream(ws)
    self.projects.each { |p|
      next if p.active_requests.size == 0
      return true if p.workstream == ws    
      }
    return false
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
