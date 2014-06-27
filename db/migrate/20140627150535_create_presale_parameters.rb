class CreatePresaleParameters < ActiveRecord::Migration
  def self.up
    create_table :presale_parameters do |t|
    	t.integer :presale_id
    	t.integer :presale_type_id

    	t.boolean :status,  :default => true
    	t.timestamps
    end
  end

  def self.down
    drop_table :presale_parameters
  end
end
