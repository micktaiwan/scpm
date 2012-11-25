class CreatePlannings < ActiveRecord::Migration
  def self.up
    create_table :plannings do |t|
      t.string  :name
      t.integer :project_id
      t.timestamps
    end
  end

  def self.down
    drop_table :plannings
  end
end
