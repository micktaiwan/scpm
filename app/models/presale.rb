class Presale < ActiveRecord::Base
  	belongs_to  :project
    has_many    :presale_presale_types, :dependent => :nullify


    PRIORITY_NONE = -1
    PRIORITY_TOO_LATE = 1
    PRIORITY_TO_BE_FOLLOWED = 2
    PRIORTY_IN_TIME = 3
    PRIORITY_URGENT = 4
    PRIORITY_VERY_URGENT = 5

    def Presale.init_with_project(project_id)
    	presale = Presale.new
    	presale.project_id = project_id
    	presale.save
        return presale
    end

    def Presale.get_priority_message(priority_raw)
    	case priority_raw
    	when PRIORITY_NONE
    		return "None"
    	when PRIORITY_TO_BE_FOLLOWED
    		return "To be followed"
    	when PRIORTY_IN_TIME
    		return "In time"
    	when PRIORITY_URGENT
    		return "Urgent"
    	when PRIORITY_VERY_URGENT
    		return "Very urgent"
    	when PRIORITY_TOO_LATE
    		return "Too late"
    	end
    	return "Unknow"
    end
end
