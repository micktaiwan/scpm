class AddIsQrQwrToProjects < ActiveRecord::Migration
  def self.up
  	add_column :projects, :is_qr_qwr, :boolean, :default => false
  end

  def self.down
  	remove_column :projects, :is_qr_qwr
  end
end
