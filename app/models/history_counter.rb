class HistoryCounter < ActiveRecord::Base
  belongs_to :request, :dependent=>:nullify
  belongs_to :person
  belongs_to :spider
  belongs_to :status
end
