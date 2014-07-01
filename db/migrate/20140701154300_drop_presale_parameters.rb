class DropPresaleParameters < ActiveRecord::Migration
  def self.up
    drop_table :presale_parameters
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end

