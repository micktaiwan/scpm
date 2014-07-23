class CreatePresaleComments < ActiveRecord::Migration
  def self.up
    create_table :presale_comments do |t|
    	t.integer :presale_presale_type_id
    	t.text :comment
    	t.timestamps
    end
  end

  def self.down
    drop_table :presale_comments
  end
end
