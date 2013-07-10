class CreateLessonCollectFiles < ActiveRecord::Migration
  def self.up
    create_table :lesson_collect_files do |t|
      t.string	:pm
      t.string	:qwr_sqr
      t.string	:workstream
      t.string 	:suite_name
      t.string	:project_name
      t.timestamps
    end
  end

  def self.down
    drop_table :lesson_collect_files
  end
end
