class CreateLessonCollects < ActiveRecord::Migration
  def self.up
    create_table :lesson_collects do |t|
      t.integer :lesson_collect_file_id
      t.string  :lesson_id
      t.string  :milestone
      t.string  :type_lesson
      t.text    :topics
      t.text    :cause
      t.string  :improvement
      t.string  :axes
      t.string  :sub_axes
      t.timestamps
    end
  end

  def self.down
    drop_table :lesson_collects
  end
end
