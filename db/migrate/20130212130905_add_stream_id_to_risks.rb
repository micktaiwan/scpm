class AddStreamIdToRisks < ActiveRecord::Migration
  def self.up
  	add_column :risks, :stream_id, :integer
  end

  def self.down
  	remove_column :risks, :stream_id
  end
end
