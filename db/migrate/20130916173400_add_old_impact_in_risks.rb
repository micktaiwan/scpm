class AddOldImpactInRisks < ActiveRecord::Migration
  def self.up
  	add_column :risks, :old_impact, :integer, :default=> 0
  end

  def self.down
  	remove_column :risks, :old_impact
  end
end
