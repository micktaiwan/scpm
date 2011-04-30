class CreateRisks < ActiveRecord::Migration
  def self.up
    create_table :risks do |t|
      t.integer :project_id
      t.integer :probability
      t.integer :impact
      t.text    :context
      t.text    :risk
      t.text    :consequence
      t.text    :actions
      t.timestamps
    end
  end


  def self.down
    drop_table :risks
  end
end
