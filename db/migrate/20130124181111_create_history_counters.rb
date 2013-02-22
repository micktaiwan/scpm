class CreateHistoryCounters < ActiveRecord::Migration
  def self.up
    create_table  :history_counters do |t|
      t.integer   :request_id
      t.datetime  :action_date
      t.integer   :author_id
      t.integer   :concerned_status_id
      t.integer   :concerned_spider_id
      t.integer   :stream_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :history_counters
  end
end
