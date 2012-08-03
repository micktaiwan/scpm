class AddIsCpdpToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :is_cpdp, :integer, :default => 0
  end

  def self.down
    remove_column :people, :is_cpdp
  end
end
