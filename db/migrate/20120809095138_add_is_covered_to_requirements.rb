class AddIsCoveredToRequirements < ActiveRecord::Migration
  def self.up
    add_column :requirements, :is_covered, :string
  end

  def self.down
    remove_column :requirements, :is_covered
  end
end
