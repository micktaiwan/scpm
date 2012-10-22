class CreateSpiderConsolidations < ActiveRecord::Migration
  def self.up
    create_table :spider_consolidations do |t|
      t.integer :spider_id
      t.integer :average
      t.integer :average_ref
      t.integer :ni_number
      t.timestamps
    end
  end

  def self.down
    drop_table :spider_consolidations
  end
end
