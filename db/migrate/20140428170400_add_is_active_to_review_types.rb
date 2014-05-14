class AddIsActiveToReviewTypes < ActiveRecord::Migration
  def self.up
    add_column :review_types, :is_active, :boolean, :default => true
  end

  def self.down
    add_column :review_types, :is_active
  end
end
