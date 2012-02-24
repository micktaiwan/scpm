class AddLongDescriptionToReqs < ActiveRecord::Migration
  def self.up
  	add_column :requirements, :long_description, :text
  	add_column :requirement_versions, :long_description, :text
  end

  def self.down
  	remove_column :requirements, :long_description
  	remove_column :requirement_versions, :long_description
  end
end
