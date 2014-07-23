class TbpProject < ActiveRecord::Base

  has_one :project #, :class_name=>'TbpProject', :foreign_key=>"tbp_project_id", :primary_key=>"tbp_id"

end
