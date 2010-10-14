class Action < ActiveRecord::Base

  belongs_to :person
  belongs_to :project
  
  def person_name
    return person.name if person
    ""
  end
  
  def project_full_name
    return project.full_name if project
    ""
  end
  
end
