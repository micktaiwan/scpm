class Status < ActiveRecord::Base

  belongs_to :project

  def is_current?
    self.updated_at.to_date.cweek == Date.today.cweek
  end
  
  def get_last_change_excel
    return self.last_change_excel if self.last_change_excel
    self.last_change
  end

end
