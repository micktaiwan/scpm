class PresalePresaleType < ActiveRecord::Base
  	belongs_to  :presale
  	belongs_to  :presale_type
end
