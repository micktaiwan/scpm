class AddCalendarIdInHolidays < ActiveRecord::Migration
  def self.up
  	add_column :wl_holidays, :wl_holidays_calendar_id, :integer

    holidays = WlHoliday.find(:all)
    holidays.each  do |h|
      h.wl_holidays_calendar_id = HolidaysCalendar.first.id
      h.save
    end
  end

  def self.down
  	remove_column :wl_holidays, :wl_holidays_calendar_id
  end
end
