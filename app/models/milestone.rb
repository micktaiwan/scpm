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
    return "passed" if done == 1
    return "skipped" if done == 2
    d = date
    if d.blank?
      return "missing" if status != -1
      return "blank"
    end
    diff = d - Date.today
    return "verysoon" if diff <= 5
    return "soon" if diff <= 10
    return "normal"
  end

  def amendments
    self.project.amendments.select{|a| a.milestone == self.name}
  end

  #def rmt_alerts
  #  alerts = []
  #  alerts << "RMT milestone date is not the same" if self.name == 'm3' and project.requests.select{|r| r.milestone=="M1-M3"}.size > 0
  #  alerts
  #end

end

