class AddRoleDescription < ActiveRecord::Migration
  def self.up
    add_column :roles, :display, :string
    add_column :roles, :description, :text
  end

  def self.down
    remove_column :roles, :description
    remove_column :roles, :display
  end
end
