class CreateLineTags < ActiveRecord::Migration
  def self.up
    create_table :line_tags do |t|
    	t.integer :line_id
    	t.integer :tag_id
      	t.timestamps
    end
  end

  def self.down
    drop_table :line_tags
  end
end
