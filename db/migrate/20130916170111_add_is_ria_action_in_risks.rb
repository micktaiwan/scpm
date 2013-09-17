class AddIsRiaActionInRisks < ActiveRecord::Migration
  def self.up
  	add_column :risks, :is_ria_action, :boolean, :default => false
  end

  def self.down
  	remove_column :risks, :is_ria_action
  end
end
