class AddIsPersonTransverse < ActiveRecord::Migration
  def self.up
    add_column :people, :is_transverse, :integer, :default=>0
  end

  def self.down
    remove_column :people,:is_transverse
  end
end
