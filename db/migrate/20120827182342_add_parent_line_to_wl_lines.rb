class AddParentLineToWlLines < ActiveRecord::Migration
  def self.up
    add_column :wl_lines, :parent_line, :integer
  end

  def self.down
    remove_column :wl_lines, :parent_line
  end
end
