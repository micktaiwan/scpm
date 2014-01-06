class MonthlyTask < ActiveRecord::Base
  has_many   :monthly_task_people
  has_many   :people, :through => :monthly_task_people


  def has_person?(person)
    self.people.count(:conditions => ['people.id = ?', person.id.to_s]) > 0
  end

  def add_person(person)
    return if self.has_person?(person)
    self.people << person
  end

  def remove_person(person)
    return if not self.has_person?(person)
    self.people.delete(person)
  end

end
