class Risk < ActiveRecord::Base

  belongs_to :project
  belongs_to :stream
  belongs_to :generic_risk

  before_save :save_action


  PROBABILITY = [0,1,2,3,4]
  IMPACT      = [1,2,3,4]

  # SEVERITY COLORS
  ZERO_SEVERITY     = "#DDDDDD"
  LOW_SEVERITY      = "#82CA3F"
  MEDIUM_SEVERITY   = "#FFFF0A"
  HIGH_SEVERITY     = "#FDB409"
  CRITICAL_SEVERITY = "#FB0007"

  # SEVERITY EXCEL STYLES
  ZERO_SEVERITY_EXCEL     = "s91"
  LOW_SEVERITY_EXCEL      = "s92"
  MEDIUM_SEVERITY_EXCEL   = "s93"
  HIGH_SEVERITY_EXCEL     = "s94"
  CRITICAL_SEVERITY_EXCEL = "s95"



  # colorArray[0] = Probability 0
  # colorArray[1] = Probability 1
  # colorArray[2] = Probability 2
  # colorArray[3] = Probability 3
  # colorArray[3] = Probability 4
  # colorArray[1][0] = Probability 1 / Impact 1
  # colorArray[1][1] = Probability 1 / Impact 2
  # colorArray[1][2] = Probability 1 / Impact 3
  # colorArray[1][3] = Probability 1 / Impact 4
  COLOR_ARRAY = [[ZERO_SEVERITY,ZERO_SEVERITY,ZERO_SEVERITY,ZERO_SEVERITY],
    [LOW_SEVERITY,LOW_SEVERITY,MEDIUM_SEVERITY,MEDIUM_SEVERITY],
    [LOW_SEVERITY,MEDIUM_SEVERITY,HIGH_SEVERITY,HIGH_SEVERITY],
    [LOW_SEVERITY,MEDIUM_SEVERITY,HIGH_SEVERITY,CRITICAL_SEVERITY],
    [MEDIUM_SEVERITY,MEDIUM_SEVERITY,HIGH_SEVERITY,CRITICAL_SEVERITY]]

  COLOR_ARRAY_EXCEL = [[ZERO_SEVERITY_EXCEL, ZERO_SEVERITY_EXCEL, ZERO_SEVERITY_EXCEL, ZERO_SEVERITY_EXCEL],
    [LOW_SEVERITY_EXCEL, LOW_SEVERITY_EXCEL, MEDIUM_SEVERITY_EXCEL, MEDIUM_SEVERITY_EXCEL],
    [LOW_SEVERITY_EXCEL, MEDIUM_SEVERITY_EXCEL, HIGH_SEVERITY_EXCEL, HIGH_SEVERITY_EXCEL],
    [LOW_SEVERITY_EXCEL, MEDIUM_SEVERITY_EXCEL, HIGH_SEVERITY_EXCEL, CRITICAL_SEVERITY_EXCEL],
    [MEDIUM_SEVERITY_EXCEL, MEDIUM_SEVERITY_EXCEL, HIGH_SEVERITY_EXCEL, CRITICAL_SEVERITY_EXCEL]]

  def severity
    self.probability * self.impact
  end

  def old_severity
    self.old_probability * self.old_impact
  end

  def save_action
    if self.impact_was != nil
      self.old_impact = self.impact_was
    end
    if self.probability_was != nil
      self.old_probability = self.probability_was
    end
  end

  def severity_excel_style
    if ((self.probability >= 0 and self.probability <= 4) and (self.impact >= 1 and self.impact <= 4))
      return {'ss:StyleID' => COLOR_ARRAY_EXCEL[self.probability][self.impact-1] }
    end
    return {'ss:StyleID' => ZERO_SEVERITY_EXCEL }
  end

  def probability_excel_style
    case
      when probability < 4
        return {'ss:StyleID' => 'Default'}
      else
        return {'ss:StyleID' => 's84'}
    end    
  end

  def old_severity_excel_style
    if ((self.old_probability >= 0 and self.old_probability <= 4) and (self.old_impact >= 1 and self.old_impact <= 4))
      return {'ss:StyleID' => COLOR_ARRAY_EXCEL[self.old_probability][self.old_impact-1] }
    end
    return {'ss:StyleID' => ZERO_SEVERITY_EXCEL }
  end

  def old_probability_excel_style
    case
      when old_probability < 4
        return {'ss:StyleID' => 'Default'}
      else
        return {'ss:StyleID' => 's84'}
    end    
  end

  def get_severity_color
    if ((self.probability >= 0 and self.probability <= 4) and (self.impact >= 1 and self.impact <= 4))
      return COLOR_ARRAY[self.probability][self.impact-1]
    end
    return ZERO_SEVERITY
  end

  def isLow?
    if self.get_severity_color == LOW_SEVERITY
      return true
    end
    return false
  end

  def isMedium?
    if self.get_severity_color == MEDIUM_SEVERITY
      return true
    end
    return false
  end

  def isHigh?
    if self.get_severity_color == HIGH_SEVERITY
      return true
    end
    return false
  end

  def isCritical?
    if self.get_severity_color == CRITICAL_SEVERITY
      return true
    end
    return false
  end

end
