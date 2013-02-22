class CounterLog < ActiveRecord::Base
  belongs_to  :request #, :dependent=>:nullify
end
