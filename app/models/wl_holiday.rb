class WlHoliday < ActiveRecord::Base

  def self.get_from_week(wlweek)
    h = WlHoliday.find_by_week(wlweek)
    return h.nb if h
    0
  end

end
