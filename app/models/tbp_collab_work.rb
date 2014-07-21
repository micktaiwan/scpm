class TbpCollabWork < ActiveRecord::Base

  belongs_to :project, :class_name=>'TbpProject', :foreign_key=>"tbp_project_id", :primary_key=>"tbp_id"

  def project_name
    if project
      project.name
    else
      "no project"
    end
  end

end
