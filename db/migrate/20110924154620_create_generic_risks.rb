class CreateGenericRisks < ActiveRecord::Migration
  def self.up
    create_table :generic_risks do |t|
      t.integer :generic_risk_question_id
      t.integer :is_quality
      t.timestamps
      t.text :context
      t.text :risk
      t.text :consequence
      t.text :actions
    end
  end

  def self.down
    drop_table :generic_risks
  end
end
