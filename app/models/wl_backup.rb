class WlBackup < ActiveRecord::Base
  belongs_to :person
  belongs_to :wl_line
end
