class PresaleType < ActiveRecord::Base
	has_many    :presale_presale_types, :dependent => :nullify
	has_many	:presale_ignore_projects
  	has_many    :ignored_projects, :through=>:presale_ignore_projects
end
