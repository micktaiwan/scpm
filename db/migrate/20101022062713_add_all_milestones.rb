class AddAllMilestones < ActiveRecord::Migration
  def self.up
    Project.find(:all).select{ |p| p.has_requests}.each { |p|
      p.create_milestones
      puts p.full_name
      }
  end

  def self.down
  end
end
