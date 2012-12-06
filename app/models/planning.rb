class Planning < ActiveRecord::Base

  has_many :tasks, :order=>"start_date, end_date"

  # construct an array of nb of person needed (CMMI PP12)
  def team_size_array
    rv = []
    earlier = self.earlier_task.try(:start_date)
    latest  = self.latest_task.try(:end_date)
    return rv if !earlier or !latest
    current_date = earlier
    while(current_date <= latest)
      rv << [current_date, get_team_size_for_day(current_date)]
      current_date += 1.day
    end
    rv
  end

  def get_team_size_for_day(date)
    rv = 0
    self.tasks.each { |t|
      rv += ((t.team_size / 0.1).round)*0.1 if date >= t.start_date and (t.end_date and date < t.end_date)
      }
    rv
  end

  def earlier_task
    rv = nil # returning does not work ???
    self.tasks.each { |t| rv = t if !rv or t.start_date < rv.start_date }
    rv
  end

  def latest_task
    rv = nil
    self.tasks.each { |t| rv = t if !rv or (t.end_date and t.end_date > rv.end_date) }
    rv
  end

end
