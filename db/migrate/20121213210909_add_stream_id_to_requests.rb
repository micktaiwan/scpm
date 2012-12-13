class AddStreamIdToRequests < ActiveRecord::Migration
  def self.up
  	add_column :requests, :stream_id, :integer, :default=> nil
  end

  def self.down
  	remove_column :requests, :stream_id
  end
end
