class Topic < ActiveRecord::Base

  belongs_to :person

  def person_name
    self.person.name
  end

  def dates
    rv = self.created_at.to_date.to_s
    rv += " / " +  self.done_date.to_date.to_s if self.done == 1
    rv
  end

end

