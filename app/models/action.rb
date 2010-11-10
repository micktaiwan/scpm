class Action < ActiveRecord::Base

  belongs_to :person
  belongs_to :project
  
  before_save :track_changes
  
  def person_name
    return person.name if person
    ""
  end
  
  def project_full_name
    return project.full_name if project
    ""
  end

private
  
  def track_changes
    self.result = self.result + " changed from project #{self.project_id_was}, #{Project.find(self.project_id_was).name}" if self.project_id_changed?
  end
  
end
