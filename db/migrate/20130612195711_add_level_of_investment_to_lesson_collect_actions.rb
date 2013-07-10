class AddLevelOfInvestmentToLessonCollectActions < ActiveRecord::Migration
  def self.up
  	add_column :lesson_collect_actions, :level_of_investment, :integer
  end

  def self.down
  	remove_column :lesson_collect_actions, :level_of_investment
  end
end
