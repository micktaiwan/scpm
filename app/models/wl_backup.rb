class WlBackup < ActiveRecord::Base
  belongs_to :person
  belongs_to :backup, :class_name => "Person", :foreign_key => "backup_person_id"
  belongs_to :wl_line
end
