class AddStatusFeedback < ActiveRecord::Migration
  def self.up
    add_column :statuses, :feedback, :text
  end

  def self.down
    remove_column :statuses, :feedback
  end
end
