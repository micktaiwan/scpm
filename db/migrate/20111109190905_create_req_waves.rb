class CreateReqWaves < ActiveRecord::Migration
  def self.up
    create_table :req_waves do |t|
      t.string  :name
      t.integer :status, :default=>0
      t.timestamps
    end
  end

  def self.down
    drop_table :req_waves
  end
end

