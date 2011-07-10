class CreateWlLoads < ActiveRecord::Migration
  def self.up
    create_table :wl_loads do |t|
      t.integer :wl_line_id
      t.integer :week # year + week number: 201128, 201201
      t.float   :wlload # 0.125
      t.timestamps
    end
  end

  def self.down
    drop_table :wl_loads
  end
end
