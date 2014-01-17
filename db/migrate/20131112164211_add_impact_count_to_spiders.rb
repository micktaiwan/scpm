class AddImpactCountToSpiders < ActiveRecord::Migration
  def self.up
  	add_column :spiders, :impact_count, :boolean, :default => false
  end

  def self.down
  	remove_column :spiders, :impact_count
  end
end
