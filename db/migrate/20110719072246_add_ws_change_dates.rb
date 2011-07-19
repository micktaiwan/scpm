class AddWsChangeDates < ActiveRecord::Migration
  def self.up
    now = Time.now.utc
    add_column :statuses, :reason_updated_at, :datetime, :default=>now
    add_column :statuses, :ws_updated_at,     :datetime, :default=>now    
  end

  def self.down
    remove_column :statuses, :reason_updated_at
    remove_column :statuses, :ws_updated_at
  end
end
