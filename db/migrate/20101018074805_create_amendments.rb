class CreateAmendments < ActiveRecord::Migration
  def self.up
    create_table :amendments do |t|
      t.integer :project_id
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
