class QuestionReference < ActiveRecord::Base
  belongs_to :lifecycle_question, :foreign_key=>"question_id"
  belongs_to :milestone_name,  :foreign_key=>"milestone_id"
end
