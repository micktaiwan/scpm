require 'acts_as_versioned'

class Requirement < ActiveRecord::Base
  acts_as_versioned

  belongs_to :req_category
  belongs_to :req_wave

  Req_Status = [['Proposed', 100], ['Reviewed', 200], ['Approved by SQLI', 300],
   ['Conception in progress', 400], ['Validated by SQLI', 500], ['Refused by customer', 600],
   ['Accepted by customer', 700], ['Realisation in progress', 800], ['Deployed', 900],
   ['Superseded', 1000], ['Deleted', 1100]]

  def status_name
    for s in Req_Status
      return s[0] if self.status == s[1]
    end
    return "Error: unknown status #{s[1]}"
  end

end

