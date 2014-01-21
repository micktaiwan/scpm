class MonthlyTask < ActiveRecord::Base
  has_many   :monthly_task_people
  has_many   :people, :through => :monthly_task_people
  belongs_to :monthly_task_type


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

  def get_tasks_export
    date = (Date.today-1.month).strftime("%d/%m/%Y")
    tasks = Array.new
    self.people.each do |p|
      tasks << self.monthly_task_type.get_template_filled(self.title, self.load_value, p.login, date)
    end
    return tasks
  end

end
