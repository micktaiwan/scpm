class AddLastReviewToRequirementVersions < ActiveRecord::Migration
  def self.up
    add_column :requirement_versions, :last_review, :date
  end

  def self.down
    remove_column :requirement_versions, :last_review
  end
end
