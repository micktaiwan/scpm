class LifecycleMilestone < ActiveRecord::Base
  belongs_to :lifecycle
  belongs_to :milestone_name
end
