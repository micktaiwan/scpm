class PresaleType < ActiveRecord::Base
	has_many    :presale_presale_types, :dependent => :nullify
end
