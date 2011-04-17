class CreateSdpTasks < ActiveRecord::Migration
  def self.up
    create_table :sdp_tasks do |t|
      t.integer :sdp_id
      t.integer :activity_id
      t.integer :phase_id
      t.string  :title
      t.integer :done, :default=>0
      t.integer :initial
      t.integer :reevaluated
      t.integer :assigned
      t.integer :consumed
      t.integer :remaining
      t.integer :revised
      t.integer :gained
      t.integer :revised
      t.integer :iteration
      t.integer :collab
      t.integer :balance      
      t.timestamps
    end
  end

  def self.down
    drop_table :sdp_tasks
  end
end
