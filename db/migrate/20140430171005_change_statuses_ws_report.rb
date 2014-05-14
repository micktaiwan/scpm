class ChangeStatusesWsReport < ActiveRecord::Migration
  def self.up
    rename_column :statuses, :ws_report, :reporting   
    rename_column :statuses, :ws_updated_at, :reporting_at  

  end

  def self.down
    rename_column :statuses, :reporting, :ws_report   
    rename_column :statuses, :reporting_at, :ws_updated_at  
  end
end
