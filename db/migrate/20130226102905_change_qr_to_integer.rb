class ChangeQrToInteger < ActiveRecord::Migration
  def self.up
    change_column :projects, :qr, :integer
  end

  def self.down
    change_column :projects, :qr, :string
  end
end
