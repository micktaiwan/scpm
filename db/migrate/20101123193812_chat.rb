class Chat < ActiveRecord::Migration
  def self.up
    add_column :people, :last_view, :datetime
  end

  def self.down
    remove_column :people, :lastview
  end
end

