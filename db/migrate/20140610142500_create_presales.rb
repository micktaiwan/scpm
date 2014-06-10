class CreatePresales < ActiveRecord::Migration
  def self.up
    create_table :presales do |t|
      t.timestamps
    end
  end

  def self.down
    drop_table :presales
  end
end
