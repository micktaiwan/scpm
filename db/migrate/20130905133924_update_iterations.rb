class UpdateIterations < ActiveRecord::Migration
  def self.up
  	iterations = SDPTask.find(:all, :conditions=>["iteration is not null"]).map{|sdp| [sdp.iteration, sdp.project_code]}.uniq
  	iterations.each { |f|
  		Iteration.create(:name => f[0], :project_code => f[1])
  	}
  end

  def self.down
  end
end
