class AddContreVisites < ActiveRecord::Migration
  def self.up
    add_column :requests, :contre_visite, :string
  end

  def self.down
    remove_column :requests, :contre_visite
  end
end

