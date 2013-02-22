class AddFileLinkToStatuses < ActiveRecord::Migration
  def self.up
  	add_column :statuses, :file_link, :string
  end

  def self.down
  	remove_column :statuses, :file_link
  end
end
