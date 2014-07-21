class CreateTbpProjects < ActiveRecord::Migration
  def self.up
    create_table :tbp_projects do |t|
      t.integer :tbp_id
      t.string  :name
      t.integer :activity
      t.integer :ttype
      t.string  :agresso
      t.timestamps
    end
  end

  def self.down
    drop_table :tbp_projects
  end
end
