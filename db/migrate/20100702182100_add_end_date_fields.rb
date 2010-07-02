class AddEndDateFields < ActiveRecord::Migration
  def self.up
    add_column :requests, :actual_m_date, :string
  end

  def self.down
    remove_column :requests, :actual_m_date
  end
end
