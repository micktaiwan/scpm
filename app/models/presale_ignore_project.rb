class PresaleIgnoreProject < ActiveRecord::Base
	belongs_to  :project
	belongs_to  :presale_type
end
