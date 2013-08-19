class WlHoliday < ActiveRecord::Base

  def self.get_from_week(wlweek)
    h = WlHoliday.find_by_week(wlweek) #and_company
    return h.nb if h
    0
  end

end
