class AddPeopleLeft < ActiveRecord::Migration
  def self.up
    add_column :people, :has_left, :integer, :default=>0
  end

  def self.down
    remove_column :people, :has_left
  end
end
