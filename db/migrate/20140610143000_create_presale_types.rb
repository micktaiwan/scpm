class CreatePresaleTypes < ActiveRecord::Migration
  def self.up
    create_table :presale_types do |t|
    	t.integer :title
    	t.timestamps
    end
  end

  def self.down
    drop_table :presale_types
  end
end
