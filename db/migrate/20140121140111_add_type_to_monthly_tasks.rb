class AddTypeToMonthlyTasks < ActiveRecord::Migration
  def self.up
  	add_column :monthly_tasks, :monthly_task_type_id, :integer
  end

  def self.down
  	remove_column :monthly_tasks, :monthly_task_type_id
  end
end
