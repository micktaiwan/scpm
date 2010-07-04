class AddEndDateFields < ActiveRecord::Migration
  def self.up
    add_column :requests, :actual_m_date, :string
    add_column :requests, :end_date, :string
  end

  def self.down
    remove_column :requests, :actual_m_date
    remove_column :requests, :end_date
  end
end
