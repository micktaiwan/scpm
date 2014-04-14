class CreateWlBackups < ActiveRecord::Migration
  def self.up
    create_table :wl_backups do |t|
	  t.integer :person_id
	  t.integer :wl_line_id
      t.timestamps
    end
  end

  def self.down
    drop_table :wl_backups
  end
end
