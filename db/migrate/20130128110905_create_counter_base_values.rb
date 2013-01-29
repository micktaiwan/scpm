class CreateCounterBaseValues < ActiveRecord::Migration
  def self.up
    create_table :counter_base_values do |t|
      t.string  :complexity
      t.string  :operational_year
      t.integer :value
      t.timestamps
    end
  end

  def self.down
    drop_table :counter_base_values
  end
end
