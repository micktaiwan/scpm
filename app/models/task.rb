class Task < ActiveRecord::Base

  belongs_to  :planning
  before_save   :adjust_start_date
  before_save   :calculate_end_date_or_work

  include Util

  # verify if start date is not a holiday
  def adjust_start_date
    wday = self.start_date.wday
    self.start_date += 1.day if wday == 0
    self.start_date += 2.day if wday == 6
  end

  def calculate_end_date_or_work
    self.end_date = Util.real_end_date(self.start_date, self.work_in_day)
  end

end
