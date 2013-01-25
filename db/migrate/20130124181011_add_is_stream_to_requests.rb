class AddIsStreamToRequests < ActiveRecord::Migration
  def self.up
  	add_column :requests, :is_stream, :boolean, :default=>0
  end

  def self.down
  	remove_column :requests, :is_stream
  end
end
