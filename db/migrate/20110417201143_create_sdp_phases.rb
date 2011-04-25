class CreateSdpPhases < ActiveRecord::Migration
  def self.up
    create_table :sdp_phases do |t|
      t.string  :title
      t.float :initial
      t.float :reevaluated
      t.float :assigned
      t.float :consumed
      t.float :remaining
      t.float :revised
      t.float :gained
      t.float :revised
      t.float :iteration
      t.float :collab
      t.float :balancei
      t.float :balancer
      t.float :balancea
      t.timestamps
    end
  end

  def self.down
    drop_table :sdp_phases
  end
end
