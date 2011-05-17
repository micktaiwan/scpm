class AddWsReporting < ActiveRecord::Migration
  def self.up
    add_column :statuses, :ws_report, :text
  end

  def self.down
    remove_column :statuses, :ws_report
  end
end
