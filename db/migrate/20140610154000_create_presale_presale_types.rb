class CreatePresalePresaleTypes < ActiveRecord::Migration
  def self.up
    create_table :presale_presale_types do |t|
    	t.integer :presale_id
    	t.integer :presale_type_id

      t.integer :opportunity_number
      t.integer :milestone_date
      t.string  :status
      t.string  :complexity
      t.date    :buyside_launch_date
      t.date    :buyside_accepted_date
    	t.timestamps
    end
  end

  def self.down
    drop_table :presale_presale_types
  end
end
