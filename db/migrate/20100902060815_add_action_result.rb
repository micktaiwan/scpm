class AddActionResult < ActiveRecord::Migration
  def self.up
    add_column :actions, :result, :text 
  end

  def self.down
    remove_column :actions, :result
  end
end
