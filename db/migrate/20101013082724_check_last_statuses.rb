class CheckLastStatuses < ActiveRecord::Migration
  def self.up
    #p = Project.find(30)
    #p.update_status(2)
    for p in Project.all
      puts p.name if p.has_status and p.last_status != p.get_status.status
      p.propagate_status
    end
  end

  def self.down
  end
end
