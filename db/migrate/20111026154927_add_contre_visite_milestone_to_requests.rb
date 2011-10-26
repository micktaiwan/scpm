class AddContreVisiteMilestoneToRequests < ActiveRecord::Migration
  def self.up
    add_column :requests, :contre_visite_milestone, :string
  end

  def self.down
    remove_column :requests, :contre_visite_milestone
  end
end
