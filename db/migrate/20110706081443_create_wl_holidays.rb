class CreateWlHolidays < ActiveRecord::Migration
  def self.up
    create_table :wl_holidays do |t|
      t.integer :week
      t.integer :nb
      t.timestamps
    end
  end

  def self.down
    drop_table :wl_holidays
  end
end
