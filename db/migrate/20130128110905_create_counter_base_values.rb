class CreateCounterBaseValues < ActiveRecord::Migration
  def self.up
    create_table :counter_base_values do |t|
      t.string  :complexity
      t.string  :sdp_iteration
      t.string  :workpackage
      t.integer :value
      t.timestamps
    end
  end

  def self.down
    drop_table :counter_base_values
  end
end
