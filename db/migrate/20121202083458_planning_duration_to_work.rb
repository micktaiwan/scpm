class PlanningDurationToWork < ActiveRecord::Migration
  def self.up
  	rename_column :tasks, :duration_in_day, :work_in_day
  end

  def self.down
  	rename_column :tasks, :work_in_day, :duration_in_day
  end
end
