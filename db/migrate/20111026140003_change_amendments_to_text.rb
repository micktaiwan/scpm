class ChangeAmendmentsToText < ActiveRecord::Migration
  def self.up
    change_column :amendments, :amendment, :text
    change_column :amendments, :action, :text
  end

  def self.down
    change_column :amendments, :amendment, :string
    change_column :amendments, :action, :string
  end
end
