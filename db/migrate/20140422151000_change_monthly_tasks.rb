class ChangeMonthlyTasks < ActiveRecord::Migration
  def self.up
    change_column :monthly_tasks, :load_value, :float
  end

  def self.down
    change_column :monthly_tasks, :load_value, :int
  end
end
