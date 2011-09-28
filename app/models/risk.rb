class Risk < ActiveRecord::Base

  belongs_to :project
  belongs_to :generic_risk

  PROBABILITY = [0,1,2,3,4]
  IMPACT      = [1,2,3]

  def severity
    self.probability * self.impact
  end
  
  def severity_excel_style
    case
      when severity <= 4
        return {'ss:StyleID' => 's82'}
      when severity <= 6
        return {'ss:StyleID' => 's83'}
      when severity > 6
        return {'ss:StyleID' => 's84'}
    end    
  end

  def probability_excel_style
    case
      when probability < 4
        return {'ss:StyleID' => 'Default'}
      else
        return {'ss:StyleID' => 's84'}
    end    
  end

end
