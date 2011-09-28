class GenericRiskQuestion < ActiveRecord::Base

  belongs_to :capi_axis
  has_many :generic_risks, :dependent=>:destroy

  def css_class
    case
      when deployed==1
        "generic_risk_question deployed"
      else
        "generic_risk_question not_deployed"
    end
  end

end

