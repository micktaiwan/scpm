class AddPmField < ActiveRecord::Migration
  def self.up
    add_column :requests, :pm, :string
  end

  def self.down
    remove_column :requests, :pm
  end
end
