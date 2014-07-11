class PresaleComment < ActiveRecord::Base
  	belongs_to	:presale_presale_type
  	belongs_to	:person
end
