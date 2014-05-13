class Pp4 < ActiveRecord::Migration
  def self.up
  	create_table :cost_profiles do |t|
      t.string  :name
      t.integer :cost
      t.integer :company_id
      t.timestamps
    end

    add_column :people, :cost_profile_id, :integer
  end

  def self.down
  	drop_table :cost_profiles
    remove_column :people, :cost_profile_id
  end
end
