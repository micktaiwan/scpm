class CreateTbpCollabs < ActiveRecord::Migration
  def self.up
    create_table :tbp_collabs do |t|
      t.integer :tbp_id
      t.string 	:firstname
      t.string 	:lastname
      t.integer :activity
      t.integer :profil
      t.integer :te
      t.timestamps
    end
  end

  def self.down
    drop_table :tbp_collabs
  end
end
