class CreateWlLines < ActiveRecord::Migration
  def self.up
    create_table :wl_lines do |t|
      t.integer :person_id
      t.integer :request_id
      t.string  :name
      t.integer :wl_type # holidays, project, etc....
      t.string  :color
      t.timestamps
    end
  end

  def self.down
    drop_table :wl_lines
  end
end
