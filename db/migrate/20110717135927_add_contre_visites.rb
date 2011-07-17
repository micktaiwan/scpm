class AddContreVisites < ActiveRecord::Migration
  def self.up
    add_column :requests, :contre_visite, :string
    add_column :requests, :sdpiteration, :string
  end

  def self.down
    remove_column :requests, :contre_visite
    remove_column :requests, :sdpiteration
  end
end

