class AddIsCoveredToRequirementVersions < ActiveRecord::Migration
  def self.up
    add_column :requirement_versions, :is_covered, :string
  end

  def self.down
    remove_column :requirement_versions, :is_covered
  end
end
