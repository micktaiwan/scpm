class CreateStreams < ActiveRecord::Migration
  def self.up
    create_table :streams do |t|
      t.string :name
      t.integer :total_qs_count
      t.integer :total_spider_count
      t.integer  :workstream_id
      t.datetime :read_date
      t.integer  :supervisor_id
      t.string   :quality_manager
      t.string   :dwl
      t.string   :process_owner
      t.timestamps
    end
  end

  def self.down
    drop_table :streams
  end
end
