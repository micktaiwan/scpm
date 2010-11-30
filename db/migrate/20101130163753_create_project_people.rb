class CreateProjectPeople < ActiveRecord::Migration
  def self.up
    create_table :project_people, :id => false do |t|
        t.integer :project_id
        t.integer :person_id
        t.timestamps
    end
    # fill the table
    Project.all.each { |p|
      p.requests.each { |r|
        if r.assigned_to != '' and r.resolution != 'ended'
          person = Person.find_by_rmt_user(r.assigned_to)
          next if not person or ProjectPerson.find_by_project_id_and_person_id(p.id, person.id)
          p.add_responsible_from_rmt_user(r.assigned_to)
          #ProjectPerson.create(:project_id=>p.id, :person_id=>person.id)
        end
        }
      }
  end

  def self.down
    drop_table :project_people
  end
end

