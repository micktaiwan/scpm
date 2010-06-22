class AddRequestFields < ActiveRecord::Migration
  def self.up
    add_column :requests, :sdp, :string
  end

  def self.down
    remove_column :requests, :sdp
  end
end
