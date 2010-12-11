class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.text    :topic
      t.text    :decision
      t.integer :person_id
      t.integer :done, :default=>0
      t.datetime :done_date, :default=>nil
      t.integer :private, :default=>0
      t.timestamps
    end
  end

  def self.down
    drop_table :topics
  end
end

