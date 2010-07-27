class AddRmtUserToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :rmt_user, :string
  end

  def self.down
    remove_column :people, :rmt_user
  end
end
