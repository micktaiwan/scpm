class CreateMilestones < ActiveRecord::Migration
  def self.up
    create_table :milestones do |t|
      t.integer :project_id
      t.string  :name
      t.date    :milestone_date
      t.date    :actual_milestone_date
      t.integer :status
      t.text    :comments
      t.timestamps
    end
  end

  def self.down
    drop_table :milestones
  end
end
