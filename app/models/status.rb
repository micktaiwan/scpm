class Status < ActiveRecord::Base

  belongs_to :project

  def is_current?
    self.updated_at.to_date.cweek == Date.today.cweek
  end

end

