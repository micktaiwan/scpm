class PmType < ActiveRecord::Base
  has_many :pm_type_axes, :class_name=>"PmTypeAxe"
end
