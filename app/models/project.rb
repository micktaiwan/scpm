class Project < ActiveRecord::Base

  belongs_to  :project
  has_many    :projects, :order=>'name'
  has_many    :requests
  has_many    :statuses

  def html_status
    case last_status
      when 0; "<b>unknown</b>"
      when 1; "green"
      when 2; "amber"
      when 3; "<b>red</b>"
    end  
  end

  def icon_status
    case last_status
      when 0; "<img src='/images/unknown.png' align='right'>"
      when 1; "<img src='/images/green.png' align='right'>"
      when 2; "<img src='/images/amber.png' align='right'>"
      when 3; "<img src='/images/red.png' align='right'>"
    end  
  end

  def get_status
    s = Status.find(:first, :conditions=>["project_id=?", self.id], :order=>"created_at desc  ")
    s = Status.new({:status=>0, :explanation=>"unknown"}) if not s
    s
  end

end

