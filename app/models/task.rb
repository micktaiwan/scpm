class Task < ActiveRecord::Base

  belongs_to  :planning
  before_save   :adjust_start_date
  before_save   :calculate_end_date_or_work

  include Util

  # verify if start date is not a holiday
  def adjust_start_date
    # TODO
  end

  def calculate_end_date_or_work
    self.end_date = Util.real_end_date(self.start_date, self.work_in_day)
  end

end
