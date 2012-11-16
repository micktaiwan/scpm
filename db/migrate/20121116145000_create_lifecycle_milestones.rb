class CreateLifecycleMilestones < ActiveRecord::Migration
  def self.up
    create_table :lifecycle_milestones do |t|
      t.integer :lifecycle_id
      t.integer :milestone_name_id
      t.timestamps
    end
  end

  def self.down
    drop_table :lifecycle_milestones
  end
end
