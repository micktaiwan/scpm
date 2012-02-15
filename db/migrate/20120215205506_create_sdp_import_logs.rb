class CreateSdpImportLogs < ActiveRecord::Migration
  def self.up
    create_table :sdp_import_logs do |t|
      t.float :sdp_initial_balance
      t.float :sdp_real_balance
      t.float :sdp_real_balance_and_provisions
      t.float :operational_total_minus_om
      t.float :not_included_remaining
      t.float :sold
      t.float :remaining_time
      t.timestamps
    end
  end

  def self.down
    drop_table :sdp_import_logs
  end
end
