class ReviewType < ActiveRecord::Base
  has_many    :stream_reviews,    :dependent => :destroy
end
