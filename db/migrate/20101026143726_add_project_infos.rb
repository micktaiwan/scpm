class AddProjectInfos < ActiveRecord::Migration
  def self.up
    add_column :projects, :coordinator, :string
    add_column :projects, :pm, :string
    add_column :projects, :bpl, :string
    add_column :projects, :ispl, :string
    add_column :statuses, :ereporting_date, :string
  end

  def self.down
    remove_column :projects, :coordinator
    remove_column :projects, :pm
    remove_column :projects, :bpl
    remove_column :projects, :ispl
    remove_column :statuses, :ereporting_date
  end
end
