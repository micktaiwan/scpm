class CreateSpiderConsolidations < ActiveRecord::Migration
  def self.up
    create_table :spider_consolidations do |t|
      t.integer :spider_id
      t.integer :pm_type_axe_id
      t.float :average
      t.float :average_ref
      t.integer :ni_number
      t.timestamps
    end
  end

  def self.down
    drop_table :spider_consolidations
  end
end
