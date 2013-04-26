class AddFileLinkToSpiders < ActiveRecord::Migration
  def self.up
    add_column :spiders, :file_link, :string
  end

  def self.down
    remove_column :spiders, :file_link
  end
end
