class CreateHistoryCounters < ActiveRecord::Migration
  def self.up
    create_table :history_counters do |t|
      t.integer :request_id
      t.datetime :action_date
      t.integer :author
      t.integer :concerned_status_id
      t.integer :concerned_spider
      t.timestamps
    end
  end

  def self.down
    drop_table :history_counters
  end
end
