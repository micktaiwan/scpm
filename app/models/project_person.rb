class ProjectPerson < ActiveRecord::Base
  belongs_to :project
  belongs_to :person
  belongs_to :responsible, :class_name=>"Person", :foreign_key=>:person_id
end

