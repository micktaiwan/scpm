class CreateLessonCollectActions < ActiveRecord::Migration
  def self.up
    create_table :lesson_collect_actions do |t|
      t.integer :lesson_collect_file_id
      t.string   :ref
      t.date     :creation_date
      t.string   :source
      t.text     :title
      t.text     :status
      t.string   :action
      t.date     :due_date
      t.timestamps
    end
  end

  def self.down
    drop_table :lesson_collect_actions
  end
end
