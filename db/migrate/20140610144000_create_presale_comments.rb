class CreatePresaleComments < ActiveRecord::Migration
  def self.up
    create_table :presale_comments do |t|
    	t.integer :presale_id
    	t.integer :presale_type_id
    	t.timestamps
    end
  end

  def self.down
    drop_table :presale_comments
  end
end
