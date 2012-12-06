class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.integer :planning_id
      t.string  :name
      t.date    :start_date
      t.date    :end_date
      t.float   :duration_in_day
      t.float   :person_nb
      #t.integer :constraint
      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
