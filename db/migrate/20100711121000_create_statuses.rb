class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |t|
      t.integer :project_id, :null=>false
      t.integer :status, :default=>0
      t.text    :explanation
      t.timestamps
    end
  end

  def self.down
    drop_table :statuses
  end
end

