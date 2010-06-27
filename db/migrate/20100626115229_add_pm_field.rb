class AddPmField < ActiveRecord::Migration
  def self.up
    add_column :requests, :pm, :string
    add_column :requests, :milestone_date, :string
  end

  def self.down
    remove_column :requests, :pm
    remove_column :requests, :milestone_date
  end
end
