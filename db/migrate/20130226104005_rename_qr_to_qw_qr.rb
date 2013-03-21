class RenameQrToQwQr < ActiveRecord::Migration
  def self.up
    rename_column :projects, :qr, :qr_qwr_id   
  end

  def self.down
    rename_column :projects, :qr_qwr_id, :qr    
  end
end
