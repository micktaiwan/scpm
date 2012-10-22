class CreatePmTypes < ActiveRecord::Migration
  def self.up
    create_table :pm_types do |t|
      t.string :title
      t.timestamps
    end
  end

  def self.down
    drop_table :pm_types
  end
end
