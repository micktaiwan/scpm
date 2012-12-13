class CounterLog < ActiveRecord::Base
  belongs_to  :stream
  belongs_to  :project
end
