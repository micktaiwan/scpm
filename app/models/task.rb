# planning task
class Task < ActiveRecord::Base

  belongs_to  :planning
  before_save :adjust_start_date
  before_save :calculate_end_date_or_work

  # verify if start date is not a holiday
  def adjust_start_date
    wday = self.start_date.wday
    self.start_date += 1.day if wday == 0
    self.start_date += 2.day if wday == 6
  end

  def adjust_end_date
    wday = (self.end_date - 1.day).wday
    self.end_date -= 2.day if wday == 0
    self.end_date -= 1.day if wday == 6
  end

  def calculate_end_date_or_work
    if(self.end_date)
      adjust_end_date
      diff, holidays = Util.calculate_diff_and_holidays(self.start_date, self.end_date, :left)
      duration = diff - holidays
      #puts "duration: #{duration}, diff: #{diff}, holidays: #{holidays}"
    else
      duration = self.work_in_day
      self.end_date = Util.real_end_date(self.start_date, duration)
    end
    self.team_size = self.work_in_day.to_f / duration
  end

end
