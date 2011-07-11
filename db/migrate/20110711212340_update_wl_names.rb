class UpdateWlNames < ActiveRecord::Migration
  def self.up
    WlLine.find(:all, :conditions=>"wl_type=100 and request_id is not null").each { |l|
      l.name = l.request.workload_name
      l.save
      }
  end

  def self.down
  end
end

