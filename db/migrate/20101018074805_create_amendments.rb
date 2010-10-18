class CreateAmendments < ActiveRecord::Migration
  def self.up
    create_table :amendments do |t|
      t.integer :project_id
      t.string  :responsible
      t.column  :milestone, "ENUM('m1','m3', 'm5', 'm7', 'm9', 'm10', 'm10a', 'm11', 'm12', 'm13', 'm14')"
      t.string  :amendment
      t.string  :action
      t.date    :creation_date
      t.integer :done, :default=>0
      t.timestamps
    end
  end

  def self.down
    drop_table :amendments
  end
end
