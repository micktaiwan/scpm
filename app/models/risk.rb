class Risk < ActiveRecord::Base

  belongs_to :project

  PROBABILITY = [0,1,2,3,4]
  IMPACT      = [1,2,3]

  def severity
    self.probability * self.impact
  end

end
