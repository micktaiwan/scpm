class CreateMonthlyTaskTypes < ActiveRecord::Migration
  def self.up
    create_table :monthly_task_types do |t|
      t.string  :name
      t.text	:template
	  t.timestamps
    end
  end

  def self.down
    drop_table :monthly_task_types
  end
end
