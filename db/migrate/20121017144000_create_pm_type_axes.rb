class CreatePmTypeAxes < ActiveRecord::Migration
  def self.up
    create_table :pm_type_axes do |t|
      t.integer :pm_type_id
      t.string :title
      t.timestamps
    end
  end

  def self.down
    drop_table :pm_type_axes
  end
end
