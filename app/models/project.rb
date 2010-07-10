class Project < ActiveRecord::Base

  belongs_to  :project
  has_many    :projects, :order=>'name'
  has_many    :requests

  def html_status
    case last_status
      when 0; "<b>unknown</b>"
      when 1; "green"
      when 2; "amber"
      when 3; "<b>red</b>"
    end  
  end

end

