class Project < ActiveRecord::Base

  belongs_to  :project
  has_many    :projects, :order=>'name'
  has_many    :requests
  has_many    :statuses

  def html_status
    case last_status
      when 0; "<b>unknown</b>"
      when 1; "<span class='status green'>green</span>"
      when 2; "<span class='status amber'>amber</span>"
      when 3; "<span class='status red'>red</span>"
    end  
  end

  def icon_status
    case last_status
      when 0; "<img src='/images/unknown.png' align='right'>"
      when 1; "<img src='/images/green.gif' align='left'>"
      when 2; "<img src='/images/amber.gif' align='left'>"
      when 3; "<img src='/images/red.gif' align='left'>"
    end  
  end

  def get_status
    s = Status.find(:first, :conditions=>["project_id=?", self.id], :order=>"created_at desc  ")
    s = Status.new({:status=>0, :explanation=>"unknown"}) if not s
    s
  end

  # look at sub projects status and calcul its own
  def update_status
    status = 0
    self.projects.each { |p|
      status = p.last_status if status < p.last_status
      }
    self.last_status = status
    save
  end
  
  def full_name
    rv = self.name
    return self.project.full_name + " > " + rv if self.project
    rv
  end
  
end

