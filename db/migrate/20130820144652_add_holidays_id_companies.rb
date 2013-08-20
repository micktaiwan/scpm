class AddHolidaysIdCompanies < ActiveRecord::Migration
  def self.up
  	add_column :companies, :wl_holidays_calendar_id, :integer

    companies = Company.find(:all)
    companies.each  do |c|
    	c.wl_holidays_calendar_id = HolidaysCalendar.first.id
      c.save
    end
  end

  def self.down
  	remove_column :companies, :wl_holidays_calendar_id
  end
end
