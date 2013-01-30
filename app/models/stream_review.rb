class StreamReview < ActiveRecord::Base
  belongs_to  :stream
  belongs_to  :review_type
  belongs_to  :person, :foreign_key=>"author_id"
end
