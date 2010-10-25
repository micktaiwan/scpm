class AddLogins < ActiveRecord::Migration
  def self.up
    add_column :people, :login, :string
    add_column :people, :pwd, :string
  end

  def self.down
    remove_column :people, :login
    remove_column :people, :pwd
  end
end

