class AddChecklistIsNotApplicableToMilestone < ActiveRecord::Migration
  def self.up
    add_column :milestones, :checklist_not_applicable, :integer, :default=>0
  end

  def self.down
    remove_column :milestones, :checklist_not_applicable
  end
end

