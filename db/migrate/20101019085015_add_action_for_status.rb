class AddActionForStatus < ActiveRecord::Migration
  def self.up
    add_column :statuses, :last_change, :text
    add_column :statuses, :actions, :text
  end

  def self.down
    remove_column :statuses, :last_change
    remove_column :statuses, :actions
  end
end
