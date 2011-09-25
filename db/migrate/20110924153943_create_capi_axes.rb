class CreateCapiAxes < ActiveRecord::Migration
  def self.up
    create_table :capi_axes do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :capi_axes
  end
end

