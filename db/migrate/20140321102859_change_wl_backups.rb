class ChangeWlBackups < ActiveRecord::Migration
  def self.up
    remove_column :wl_backups, :wl_line_id
    add_column :wl_backups, :backup_person_id, :integer
  	add_column :wl_backups, :week, :integer # year + week number: 201128, 201201
  end

  def self.down
    remove_column :wl_backups, :backup_person_id
    remove_column :wl_backups, :week
    add_column :wl_backups, :wl_line_id, :integer
  end
end