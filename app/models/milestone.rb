class Milestone < ActiveRecord::Base

  belongs_to :project

  def date
    return self.actual_milestone_date if self.actual_milestone_date
    self.milestone_date
  end
  
  def to_s
    name
  end
  
  def timealert
    d = date
    if d.blank?
      return "missing" if status == 0
      return "blank"
    end  
    diff = d - Date.today
    return "verysoon" if diff < 0 and self.actual_milestone_date.blank?
    return "passed" if diff < 0
    return "verysoon" if diff <= 5
    return "soon" if diff <= 10
    return "normal"
  end
  
end
