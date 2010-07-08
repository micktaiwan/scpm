class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string  :name
      t.text    :description
      t.string  :brn
      t.string  :workstream
      t.integer :parent, :default=>0
      t.integer :last_status, :default=>0
      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
