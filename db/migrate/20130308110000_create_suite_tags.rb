class CreateSuiteTags < ActiveRecord::Migration
  def self.up
    create_table  :suite_tags do |t|
      t.string   :name
      t.timestamps
    end
  end

  def self.down
    drop_table :suite_tags
  end
end
