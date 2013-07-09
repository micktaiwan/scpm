class RenameActionLessonCollectActions < ActiveRecord::Migration
  def self.up
    rename_column :lesson_collect_actions, :action, :actionne
  end

  def self.down
    rename_column :lesson_collect_actions, :action, :actionne
  end
end

