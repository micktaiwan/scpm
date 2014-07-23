class CreateTbpCollabWorks < ActiveRecord::Migration
  def self.up
    create_table :tbp_collab_works do |t|
      t.integer :tbp_collab_id
      t.date    :date
      t.integer :tbp_project_id
      t.float :workload
      t.timestamps
    end
  end

  def self.down
    drop_table :tbp_collab_works
  end
end
