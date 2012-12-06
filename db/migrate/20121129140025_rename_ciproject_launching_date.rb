class RenameCiprojectLaunchingDate < ActiveRecord::Migration
  def self.up
    rename_column :ci_projects, :launching_date, :launching_date_ddmmyyyy
  end

  def self.down
    rename_column :ci_projects, :launching_date_ddmmyyyy, :launching_date
  end
end

