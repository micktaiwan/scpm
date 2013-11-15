class ChangeRiskIsRiaLogged < ActiveRecord::Migration
  def self.up
    change_column :risks, :is_ria_logged, :boolean, :default=>false
    change_column :risks, :is_ria_logged, :integer, :default=>0
  end

  def self.down
    change_column :risks, :is_ria_logged, :integer, :default=>0
    change_column :risks, :is_ria_logged, :boolean, :default=>false
  end
end
