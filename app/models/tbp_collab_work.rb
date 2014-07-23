class TbpCollabWork < ActiveRecord::Base

  belongs_to :tbp_project, :class_name=>'TbpProject', :foreign_key=>"tbp_project_id", :primary_key=>"tbp_id"

  def tbp_project_name
    if tbp_project
      tbp_project.name
    else
      "no project"
    end
  end

end
