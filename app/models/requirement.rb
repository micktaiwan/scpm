require 'acts_as_versioned'

class Requirement < ActiveRecord::Base
  acts_as_versioned

  belongs_to  :req_category
  belongs_to  :req_wave
  belongs_to  :person
  has_many    :req_impacts

  Req_Status = [['Proposed', 100], ['Reviewed', 200], ['Approved by SQLI', 300],
   ['Conception in progress', 400], ['Validated by SQLI', 500], ['Refused by customer', 600],
   ['Accepted by customer', 700], ['Realisation in progress', 800], ['Deployed', 900],
   ['Superseded', 1000], ['Deleted', 1100]]
  Req_Priority = [['Nice to have', 300], ['Desirable', 200], ['Mandatory', 100]]
  Req_Impact = [['Low', 300], ['High', 200], ['Very High', 100]]

  def status_name
    for s in Req_Status
      return s[0] if self.status == s[1]
    end
    return "Error: unknown status #{s[1]}"
  end

  def priority_name
    for s in Req_Priority
      return s[0] if self.priority == s[1]
    end
    return "Error: unknown priority #{s[1]}"
  end

  def css_class
    case self.status_name
    when "Deleted"
      return "req_deleted"
    when "Proposed"
      return "req_proposed"
    when "Deployed"
      return "req_deployed"
    end
    "req_normal"
  end

end

