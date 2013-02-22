class HistoryCounter < ActiveRecord::Base
  belongs_to :request #, :dependent=>:nullify
  belongs_to :author, :class_name=>"Person", :foreign_key=>"author_id"
  belongs_to :spider, :class_name=>"Spider", :foreign_key=>"concerned_spider_id"
  belongs_to :status, :class_name=>"Status", :foreign_key=>"concerned_status_id"
end
