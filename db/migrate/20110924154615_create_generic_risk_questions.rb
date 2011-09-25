class CreateGenericRiskQuestions < ActiveRecord::Migration
  def self.up
    create_table :generic_risk_questions do |t|
      t.text :question
      t.timestamps
    end
  end

  def self.down
    drop_table :generic_risk_questions
  end
end
