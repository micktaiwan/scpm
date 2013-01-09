class CreateSpiderValues < ActiveRecord::Migration
  def self.up
    create_table :spider_values do |t|
      t.integer :lifecycle_question_id
      t.integer :spider_id
      t.string :note
      t.string :reference
      t.timestamps
    end
  end

  def self.down
    drop_table :spider_values
  end
end
