class AddDoneDateToAmendments < ActiveRecord::Migration
  def self.up
    add_column :amendments, :done_date, :date
  end

  def self.down
    remove_column :amendments, :done_date
  end
end
