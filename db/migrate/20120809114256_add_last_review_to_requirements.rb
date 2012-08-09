class AddLastReviewToRequirements < ActiveRecord::Migration
  def self.up
    add_column :requirements, :last_review, :date
  end

  def self.down
    remove_column :requirements, :last_review
  end
end
