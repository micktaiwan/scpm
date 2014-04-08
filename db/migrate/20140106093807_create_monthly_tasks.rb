class CreateMonthlyTasks < ActiveRecord::Migration
  def self.up
    create_table :monthly_tasks do |t|
    	t.string :title
    	t.integer :load_value
		  t.timestamps
    end
  end

  def self.down
    drop_table :monthly_tasks
  end
end
