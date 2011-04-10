class AddProjectReadDate < ActiveRecord::Migration
  def self.up
    add_column :projects, :read_date, :datetime
  end

  def self.down
    remove_column :projects, :read_date
  end
end

