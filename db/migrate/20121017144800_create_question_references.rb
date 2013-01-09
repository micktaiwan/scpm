class CreateQuestionReferences < ActiveRecord::Migration
  def self.up
    create_table :question_references do |t|
      t.integer :question_id
      t.integer :milestone_id
      t.string :note
      t.timestamps
    end
  end

  def self.down
    drop_table :question_references
  end
end
