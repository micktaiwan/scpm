class CreateMonthlyTaskPeople < ActiveRecord::Migration
  def self.up
    create_table :monthly_task_people do |t|
      t.integer :monthly_task_id
      t.integer :person_id
		  t.timestamps
    end
  end

  def self.down
    drop_table :monthly_task_people
  end
end
