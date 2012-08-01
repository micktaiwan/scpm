class AddIsPhysicalToRequests < ActiveRecord::Migration
  def self.up
    add_column :requests, :is_physical, :string
  end

  def self.down
    remove_column :requests, :is_physical
  end
end
