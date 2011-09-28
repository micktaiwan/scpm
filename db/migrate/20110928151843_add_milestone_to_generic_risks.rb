class AddMilestoneToGenericRisks < ActiveRecord::Migration
  def self.up
    add_column :generic_risks, :milestone_name_id, :integer
    add_column :generic_risk_questions, :capis_axis_id, :integer
  end

  def self.down
    remove_column :generic_risks, :milestone_name_id
    remove_column :generic_risk_questions, :capis_axis_id
  end
end
