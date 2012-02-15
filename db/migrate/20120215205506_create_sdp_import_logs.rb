class CreateSdpImportLogs < ActiveRecord::Migration
  def self.up
    create_table :sdp_import_logs do |t|
      t.float :sdp_initial_balance, :precision=>10, :scale => 3
      t.float :sdp_real_balance, :precision=>10, :scale => 3
      t.float :sdp_real_balance_and_provisions, :precision=>10, :scale => 3
      t.float :operational_total_minus_om, :precision=>10, :scale => 3
      t.float :not_included_remaining, :precision=>10, :scale => 3
      t.float :provisions, :precision=>10, :scale => 3
      t.float :sold, :precision=>10, :scale => 3
      t.float :remaining_time, :precision=>10, :scale => 3
      t.timestamps
    end
  end

  def self.down
    drop_table :sdp_import_logs
  end
end
