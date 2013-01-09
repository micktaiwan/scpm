class CreateSpiders < ActiveRecord::Migration
  def self.up
    create_table :spiders do |t|
      t.integer :project_id
      t.integer :milestone_id
      t.timestamps
    end
  end

  def self.down
    drop_table :spiders
  end
end
