class AddDescriptionToReviewTypes < ActiveRecord::Migration
  def self.up
  	add_column :review_types, :description, :string
  end

  def self.down
  	remove_column :review_types, :description
  end
end
