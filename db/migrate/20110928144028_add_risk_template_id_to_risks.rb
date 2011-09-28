class AddRiskTemplateIdToRisks < ActiveRecord::Migration
  def self.up
    add_column :risks, :generic_risk_id, :integer
  end

  def self.down
    remove_column :risks, :generic_risk_id
  end
end
