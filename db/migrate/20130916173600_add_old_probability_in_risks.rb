class AddOldProbabilityInRisks < ActiveRecord::Migration
  def self.up
  	add_column :risks, :old_probability, :integer, :default=> 0
  end

  def self.down
  	remove_column :risks, :old_probability
  end
end
