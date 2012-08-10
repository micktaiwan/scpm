class AddClosingDateToAmendments < ActiveRecord::Migration
  def self.up
    add_column :amendments, :closing_date, :date
  end

  def self.down
    remove_column :amendments, :closing_date
  end
end
