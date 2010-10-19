class Milestone < ActiveRecord::Base

  def date
    return self.actual_milestone_date if self.actual_milestone_date
    self.milestone_date
  end
  
  def to_s
    name
  end
  
end
