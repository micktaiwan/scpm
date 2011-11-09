require 'acts_as_versioned'

class Requirement < ActiveRecord::Base
  acts_as_versioned

  belongs_to :req_category
  belongs_to :req_wave

end

