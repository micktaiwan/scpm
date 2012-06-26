class AddKickoffDateToCiProjects < ActiveRecord::Migration
  def self.up
    add_column :ci_projects, :kick_off_date, :date
  end

  def self.down
    remove_column :ci_projects, :kick_off_date
  end
end
