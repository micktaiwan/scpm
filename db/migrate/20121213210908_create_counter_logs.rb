class CreateCounterLogs < ActiveRecord::Migration
  def self.up
    create_table :counter_logs do |t|
      t.integer :project_id
      t.integer :stream_id
      t.integer :credit
      t.integer :debit
      t.timestamps
    end
  end

  def self.down
    drop_table :counter_logs
  end
end
