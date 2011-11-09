class NotesToCapi < ActiveRecord::Migration
  def self.up
    add_column :notes, :capi_axis_id, :integer, :default=>-1
  end

  def self.down
    remove_column :notes, :capi_axis_id
  end
end

