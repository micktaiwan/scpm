class ChangeSdpPhasesToDecimal < ActiveRecord::Migration
  def self.up
    change_column :sdp_phases, :balancei, :decimal, :precision => 10, :scale => 3
  end

  def self.down
    change_column :sdp_phases, :balancei, :float
  end
end
