class RenameAmendmentDuedate < ActiveRecord::Migration
  def self.up
    rename_column :amendments, :creation_date, :duedate
  end

  def self.down
    rename_column :amendments, :duedate, :creation_date
  end
end
