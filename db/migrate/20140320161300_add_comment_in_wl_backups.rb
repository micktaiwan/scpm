class AddCommentInWlBackups < ActiveRecord::Migration
  def self.up
  	add_column :wl_backups, :comment, :text
  end

  def self.down
  	remove_column :wl_backups, :comment
  end
end
