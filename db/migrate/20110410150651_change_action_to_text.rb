class ChangeActionToText < ActiveRecord::Migration
  def self.up
    change_column :actions, :action, :text
    change_column :actions, :result, :text
  end

  def self.down
    change_column :actions, :action, :string
    change_column :actions, :result, :string
  end
end
