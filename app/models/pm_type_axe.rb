class PmTypeAxe < ActiveRecord::Base
  belongs_to :pm_type
  has_many :lifecycle_questions, :dependent=>:nullify
  has_many :spider_consolidations, :dependent=>:nullify
end
