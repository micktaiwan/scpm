class AddIsQualityRisk < ActiveRecord::Migration
  def self.up
    add_column :risks, :is_quality, :integer, :default=>1
  end

  def self.down
    remove_column :risks, :is_quality
  end
end
