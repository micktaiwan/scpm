class Lifecycle < ActiveRecord::Base
  has_many :projects, :dependent=>:nullify
  has_many :lifecycle_questions, :dependent=>:nullify
  has_many :lifecycle_milestones, :dependent=>:nullify
end
