class CreateReqImpacts < ActiveRecord::Migration
  def self.up
    create_table :req_impacts do |t|
      t.integer :requirement_id
      t.integer :person_id
      t.text    :impact
      t.integer :level
      t.timestamps
    end
  end

  def self.down
    drop_table :req_impacts
  end
end

