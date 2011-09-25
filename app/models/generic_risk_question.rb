class GenericRiskQuestion < ActiveRecord::Base

  belongs_to :capi_axis
  has_many :generic_risks, :dependent=>:destroy

end

