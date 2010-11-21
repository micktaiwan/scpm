class AddMilestoneDone < ActiveRecord::Migration
  def self.up
    add_column :milestones, :done, :integer, :default=>0
    Milestone.all.each { |m|
      if m.actual_milestone_date and m.actual_milestone_date != ""
        m.done = 1
        m.save
      end
      }
  end

  def self.down
    remove_column :milestones, :done
  end
end
