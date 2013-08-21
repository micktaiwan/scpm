class WlHoliday < ActiveRecord::Base

  def self.get_from_week_and_company(wlweek, company)

    holidays = WlHoliday.find(:all, :conditions=>["week=?", wlweek])
    total = 0
    if holidays
	    holidays.each do |h|
	    	total = h.nb if h.wl_holidays_calendar_id == company.wl_holidays_calendar_id
	    end
	end
    return total
  end

end
