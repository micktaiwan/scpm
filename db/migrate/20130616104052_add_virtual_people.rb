class AddVirtualPeople < ActiveRecord::Migration
  def self.up
  	add_column :people, :is_virtual, :integer, :default=>0
  end

  def self.down
  	remove_column :people, :is_virtual
  end
end
