class AddCoverDetailToRequirementVersions < ActiveRecord::Migration
  def self.up
    add_column :requirement_versions, :cover_detail, :text
  end

  def self.down
    remove_column :requirement_versions, :cover_detail
  end
end
