class RenameLogUserToPerson < ActiveRecord::Migration
  def self.up
    rename_column :logs, :user_id, :person_id
  end

  def self.down
    rename_column :logs, :person_id, :user_id
  end
end
