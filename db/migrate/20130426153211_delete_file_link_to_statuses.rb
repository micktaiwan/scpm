class DeleteFileLinkToStatuses < ActiveRecord::Migration
  def self.up
    remove_column :statuses, :file_link
  end

  def self.down
    add_column :statuses, :file_link, :string
  end
end
