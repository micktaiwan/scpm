class AddTbpCollabIdToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :tbp_collab_id, :integer
  end

  def self.down
    remove_column :people, :tbp_collab_id
  end
end
