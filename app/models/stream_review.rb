class StreamReview < ActiveRecord::Base
  belongs_to  :stream
  belongs_to  :review_type
  belongs_to  :author, :class_name=>"Person", :foreign_key=>"author_id"
end
