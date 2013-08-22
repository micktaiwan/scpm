class Company < ActiveRecord::Base

	has_many :people, :dependent => :nullify

end
