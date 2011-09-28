class AddDeployedToGenericRiskQuestions < ActiveRecord::Migration
  def self.up
    add_column :generic_risk_questions, :deployed, :integer, :default=>0
  end

  def self.down
    remove_column :generic_risk_questions, :deployed
  end
end

