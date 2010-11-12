class AddPrivateActions < ActiveRecord::Migration
  def self.up
    add_column :actions, :private, :integer, :default=>0
  end

  def self.down
    remove_column :actions, :private
  end
end
