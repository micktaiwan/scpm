class CreateLifecycleQuestions < ActiveRecord::Migration
  def self.up
    create_table :lifecycle_questions do |t|
      t.integer :lifecycle_id
      t.integer :pm_type_axe_id
      t.string :text
      t.boolean :validity
      t.timestamps
    end
  end

  def self.down
    drop_table :lifecycle_questions
  end
end
