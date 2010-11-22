class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.text :note
      t.integer :project_id
      t.integer :private, :default=>1
      t.integer :person_id
      t.integer :note_id, :default=>0
      t.timestamps
    end
  end

  def self.down
    drop_table :notes
  end
end
