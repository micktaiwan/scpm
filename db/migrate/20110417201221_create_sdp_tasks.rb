class CreateSdpTasks < ActiveRecord::Migration
  def self.up
    create_table :sdp_tasks do |t|
      t.integer :sdp_id
      t.integer :activity_id
      t.integer :phase_id
      t.string  :title
      t.string  :request_id
      t.integer :done, :default=>0
      t.float :initial
      t.float :reevaluated
      t.float :assigned
      t.float :consumed
      t.float :remaining
      t.float :revised
      t.float :gained
      t.float :revised
      t.string :iteration
      t.string :collab
      t.float :balancei
      t.float :balancer
      t.float :balancea
      t.timestamps
    end
  end

  def self.down
    drop_table :sdp_tasks
  end
end
