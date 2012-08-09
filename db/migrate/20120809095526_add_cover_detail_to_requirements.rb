class AddCoverDetailToRequirements < ActiveRecord::Migration
  def self.up
    add_column :requirements, :cover_detail, :text
  end

  def self.down
    remove_column :requirements, :cover_detail
  end
end
