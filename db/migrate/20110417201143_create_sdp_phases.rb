class CreateSdpPhases < ActiveRecord::Migration
  def self.up
    create_table :sdp_phases do |t|
      t.string  :title
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
    drop_table :sdp_phases
  end
end
