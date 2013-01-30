class StreamReviewType < ActiveRecord::Base
  belongs_to :stream
  belongs_to :review_type
end
