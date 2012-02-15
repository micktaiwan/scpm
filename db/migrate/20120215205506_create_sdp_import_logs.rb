class CreateSdpImportLogs < ActiveRecord::Migration
  def self.up
    create_table :sdp_import_logs do |t|
      t.decimal :sdp_initial_balance, :precision=>10, :scale => 3
      t.decimal :sdp_real_balance, :precision=>10, :scale => 3
      t.decimal :sdp_real_balance_and_provisions, :precision=>10, :scale => 3
      t.decimal :operational_total_minus_om, :precision=>10, :scale => 3
      t.decimal :not_included_remaining, :precision=>10, :scale => 3
      t.decimal :provisions, :precision=>10, :scale => 3
      t.decimal :sold, :precision=>10, :scale => 3
      t.decimal :remaining_time, :precision=>10, :scale => 3
      t.timestamps
    end
  end

  def self.down
    drop_table :sdp_import_logs
  end
end
