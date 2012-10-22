class QuestionReference < ActiveRecord::Base
  belongs_to :lifecycle_question
  belongs_to :milestone_name

end
