class CreateSdpLogs < ActiveRecord::Migration
  def self.up
    create_table :sdp_logs do |t|
      t.integer :person_id
      t.date    :date
      t.float   :initial
      t.float   :sdp_remaining
      t.float   :wl_remaining
      t.float   :delay
      t.float   :balance
      t.float   :percent
      t.timestamps
    end
  end

  def self.down
    drop_table :sdp_logs
  end
end

