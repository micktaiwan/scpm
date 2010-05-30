class Center < ActiveRecord::Base

  has_one :supervisor, :through => :people
  has_one :workstreamleader, :through => :people  

end
