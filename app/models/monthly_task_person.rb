class MonthlyTaskPerson < ActiveRecord::Base
  belongs_to :monthly_task
  belongs_to :person
end
