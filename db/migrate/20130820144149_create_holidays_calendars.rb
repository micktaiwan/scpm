class CreateHolidaysCalendars < ActiveRecord::Migration
  def self.up
    create_table :holidays_calendars do |t|
      t.string :name
      t.timestamps
    end
    HolidaysCalendar.create(:name => "Default")
  end
  
  def self.down
    drop_table :holidays_calendars
  end
end