class Person < ActiveRecord::Base

  belongs_to :company

  def requests
    return [] if self.rmt_user == "" or self.rmt_user == nil
    Request.find(:all, :conditions => "assigned_to='#{self.rmt_user}'", :order=>"workstream, project_name")
  end

  def load
    requests.inject(0.0) { |sum, r| sum + r.workload}
  end
    
  def update_timeline
     File.open("#{RAILS_ROOT}/public/data/timeline_#{self.id}.xml", "w") { |f|
      requests.each { |r|
        f << "<data>"
        f << "<event start='#{Date.parse(r.gantt_start_date)}' title='#{r.project.name}' link='http://toulouse.sqli.com/EMN/'>"
        f << "#{r.summary}"
        f << "</event>"
        f << "</data>\n"
        }
      }
  end
    
end
