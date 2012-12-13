class Stream < ActiveRecord::Base
  has_many    :requests,          :dependent=>:nullify
  has_many    :stream_reviews,    :dependent => :destroy, :order=>"created_at desc"
  has_many    :counter_logs,      :dependent=>:nullify
  
  belongs_to  :workstream

  def get_consumed_qs_count
    # Get projects by workstream
    projects = Project.find(:all,:conditions => ["workstream = ?", Workstream.first(self.workstream)])
    # analyse all projects
    qs_count = 0
    projects.each do |project|
      qs_count += project.qs_count.to_i
    end
    # return
    return qs_count
  end
  def get_consumed_spider_count
    # Get projects by workstream
    projects = Project.find(:all,:conditions => ["workstream = ?", Workstream.first(self.workstream)])
    # analyse all projects
    spider_count = 0
    projects.each do |project|
      spider_count += project.spider_count.to_i
    end
    # return
    return spider_count
  end
  
  def get_stream_review
    # Get all last review for each type
    last_reviews_str = ""
    last_update = DateTime.strptime('1970-01-01 00:00:00','%Y-%m-%d %H:%M:%S')
    ReviewType.find(:all).each do |review_type|
      last_review = StreamReview.last(:conditions => ["review_type_id = ?",review_type.id])
      if last_review != nil
        last_reviews_str += "<p>" + review_type.title + "</p>" + last_review.text
        if last_review.updated_at > last_update
          last_update = last_review.updated_at
        end
      end
    end
    #return last_reviews_str
    array_return = [last_update.to_s, last_reviews_str]
    return array_return
  end


end
