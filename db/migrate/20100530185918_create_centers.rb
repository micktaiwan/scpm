class CreateCenters < ActiveRecord::Migration
  def self.up
    create_table :centers do |t|
      t.string  :name
      t.integer :supervisor_id
      t.integer :workstreamleader_id
      t.timestamps
    end
  end

  def self.down
    drop_table :centers
  end
end

