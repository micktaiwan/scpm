class Amendment < ActiveRecord::Base
  
  belongs_to :project
  before_save :check_done_status
  
  def check_done_status
    previous_amendment = Amendment.find(self.id)
    if previous_amendment.done == 0 and self.done == 1
      self.done_date = Date.today
    end
  end
end
