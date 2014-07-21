class CreateTbpCollabs < ActiveRecord::Migration
  def self.up
    create_table :tbp_collabs do |t|
      t.integer :tbp_id
      t.string 	:firstname
      t.string 	:lastname
      t.integer :activity
      t.integer :profil
      t.integer :te
      t.datetime :last_update
      t.timestamps
    end
  end

  def self.down
    drop_table :tbp_collabs
  end
end
