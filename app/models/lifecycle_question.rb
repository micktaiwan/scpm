class LifecycleQuestion < ActiveRecord::Base
  belongs_to :lifecycle
  belongs_to :pm_type_axe
  has_many :spider_values, :dependent=>:nullify
  has_many :question_references, :dependent=>:nullify
  
  
end
