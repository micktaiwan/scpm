class CreateLessonCollectAssessments < ActiveRecord::Migration
  def self.up
    create_table :lesson_collect_assessments do |t|
      t.integer  :lesson_collect_file_id
      t.integer  :lesson_id
      t.string   :milestone
      t.string   :mt_detailed_desc
      t.string   :quality_gates
      t.string   :milestones_preparation
      t.string   :project_setting_up
      t.string   :lessons_learnt
      t.string   :support_level
      t.text     :mt_improvements
      t.text     :comments
      t.timestamps
    end
  end

  def self.down
    drop_table :lesson_collect_assessments
  end
end
