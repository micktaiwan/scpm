class ChangeLessonCollectsImprovementToText < ActiveRecord::Migration
	def self.up
		change_column :lesson_collects, :improvement, :text
	end

	def self.down
		change_column :lesson_collects, :improvement, :text
	end
end

