class Presale < ActiveRecord::Base
  	belongs_to  :project
    has_many    :presale_presale_types, :dependent => :nullify


    def Presale.init_with_project(project_id)
    	presale = Presale.new
    	presale.project_id = project_id
    	presale.save
        return presale
    end
end
