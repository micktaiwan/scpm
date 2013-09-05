class UpdateIterations < ActiveRecord::Migration
  def self.up
  	iterations = SDPTask.find(:all, :conditions=>["iteration is not null"]).map{|sdp| sdp.iteration}.uniq
  	iterations.each { |i|
  		Iteration.create(:name => i)
  	}
  end

  def self.down
  end
end
