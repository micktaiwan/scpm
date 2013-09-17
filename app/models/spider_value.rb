class SpiderValue < ActiveRecord::Base
  belongs_to :spider 
  belongs_to :lifecycle_question
end
