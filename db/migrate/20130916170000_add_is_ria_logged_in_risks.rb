class AddIsRiaLoggedInRisks < ActiveRecord::Migration
  def self.up
  	add_column :risks, :is_ria_logged, :boolean, :default => false
  end

  def self.down
  	remove_column :risks, :is_ria_logged
  end
end
