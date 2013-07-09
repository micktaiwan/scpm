class AddBenefitToLessonCollectActions < ActiveRecord::Migration
  def self.up
  	add_column :lesson_collect_actions, :benefit, :integer
  end

  def self.down
  	remove_column :lesson_collect_actions, :benefit
  end
end
