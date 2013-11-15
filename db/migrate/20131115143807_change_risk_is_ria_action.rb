class ChangeRiskIsRiaAction < ActiveRecord::Migration
  def self.up
    change_column :risks, :is_ria_action, :boolean, :default=>false
    change_column :risks, :is_ria_action, :integer, :default=>0
  end

  def self.down
    change_column :risks, :is_ria_action, :integer, :default=>0
    change_column :risks, :is_ria_action, :boolean, :default=>false
  end
end
