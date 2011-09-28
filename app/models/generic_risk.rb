class GenericRisk < ActiveRecord::Base

  belongs_to :generic_risk_question
  belongs_to :milestone_name
  has_many :risks

end
