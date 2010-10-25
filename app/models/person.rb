class Person < ActiveRecord::Base

  #include Authentication

  belongs_to :company
  has_many :projects, :foreign_key=>"supervisor_id"

  has_many :person_roles
  has_many :roles, :through => :person_roles

  before_save :encrypt_password

  attr_accessor :password

  def has_role?(role)
    self.roles.count(:conditions => ['name = ?', role]) > 0
  end

  def add_role(role)
    return if self.has_role?(role)
    self.roles << Role.find_by_name(role)
  end

  def requests
    return [] if self.rmt_user == "" or self.rmt_user == nil
    Request.find(:all, :conditions => "assigned_to='#{self.rmt_user}'", :order=>"workstream, project_name")
  end

  def load
    requests.inject(0.0) { |sum, r| sum + r.workload}
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
    return nil if login.empty? or password.empty?
    self.find_by_login_and_pwd(login, self.encrypt(password))
    #puts encrypt(password)
  end

  def self.encrypt(password)
    Digest::SHA1.hexdigest("SuperSalt--#{password}--")
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
