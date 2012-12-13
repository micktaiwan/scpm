class CreateStreams < ActiveRecord::Migration
  def self.up
    create_table :streams do |t|
      t.integer :total_qs_count
      t.integer :total_spider_count
      t.integer  :workstream_id
      t.timestamps
    end
  end

  def self.down
    drop_table :streams
  end
end
