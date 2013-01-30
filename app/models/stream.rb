class Stream < ActiveRecord::Base
  has_many    :requests,          :dependent=>:nullify
  has_many    :stream_reviews,    :dependent => :destroy, :order=>"created_at desc"
  belongs_to  :workstream
  has_many    :stream_review_types
  has_many    :review_types, :through=>:stream_review_types


  #                   # 
  # Consumed tickets  #
  #                   #
  
  def get_consumed_qs_count
    # Get projects by workstream
    projects = Project.find(:all,:conditions => ["workstream = ?", Workstream.find(self.workstream).name])
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
    projects = Project.find(:all,:conditions => ["workstream = ?", Workstream.find(self.workstream).name])
    # analyse all projects
    spider_count = 0
    projects.each do |project|
      spider_count += project.spider_count.to_i
    end
    # return
    return spider_count
  end
  

  #               # 
  # Total tickets #
  #               #  
  
  def get_qs_counter
    total = 0
    self.requests.sort_by{|r| r.start_date }.each { |r|
      if ((WORKPACKAGE_QS == r.work_package[0..6]) and (r.counter_log))
         total = total + r.counter_log.counter_value
      end
    }
    return total
  end
  
  def get_spider_counter
    total = 0
    self.requests.sort_by{|r| r.start_date }.each { |r|
      if ((WORKPACKAGE_SPIDERS == r.work_package[0..6]) and (r.counter_log))
         total = total + r.counter_log.counter_value
      end
    }
    return total
  end
  
  
  #                                   # 
  # History of tickets incrementation #
  #                                   #
  
  # Create a new line in history_counter for spider
  def set_spider_history_counter(author,spider)
    request_id = self.get_current_spider_counter_request.id 
    newHistoryCounter = HistoryCounter.new
    newHistoryCounter.stream_id = self.id
    newHistoryCounter.author_id = author.id
    newHistoryCounter.concerned_spider_id = spider.id
    newHistoryCounter.action_date = DateTime.current
    if (request_id)
      newHistoryCounter.request_id = request_id
    end
    newHistoryCounter.save
  end
  
  def set_qs_history_counter(author,status)
    request_id = self.get_current_qs_counter_request.id 
    newHistoryCounter = HistoryCounter.new
    newHistoryCounter.stream_id = self.id
    newHistoryCounter.author_id = author.id
    newHistoryCounter.concerned_status_id = status.id
    newHistoryCounter.action_date = DateTime.current
    if (request_id)
      newHistoryCounter.request_id = request_id
    end
    newHistoryCounter.save
  end


  #                                                   # 
  # Retrieve the current Request (1.6.4 / 1.6.5) used #
  #                                                   #
  
  # Find the "Counter Request" for the next incrementation of spider counter 
  # For a stream, we can have multiple "Counter request" with multiple counter values.
  # This "counter request" will be order by date
  def get_current_spider_counter_request
    sum_spider_count_for_request = 0
    last_request = 0
    next_spider_counter_incrementation = self.get_consumed_spider_count + 1 # Get the next counter incrementation
    
    # loop on requests of this stream by date (!!!!!!!!!!)     
    self.requests.sort_by{|r| r.start_date }.each { |r|
       if ((WORKPACKAGE_SPIDERS == r.work_package[0..6]) and (r.counter_log))
          sum_spider_count_for_request = sum_spider_count_for_request + r.counter_log.counter_value
          last_request = r
          if (next_spider_counter_incrementation <= sum_spider_count_for_request)
            break
          end
       end
    }
    return last_request
  end
  
  def get_current_qs_counter_request
    sum_qs_count_for_request = 0
    last_request = 0
    next_qs_counter_incrementation = self.get_consumed_qs_count + 1 # Get the next counter incrementation
    
    # loop on requests of this stream by date (!!!!!!!!!!)     
    self.requests.sort_by{|r| r.start_date }.each { |r|
       if ((WORKPACKAGE_QS == r.work_package[0..6]) and (r.counter_log))
          sum_qs_count_for_request = sum_qs_count_for_request + r.counter_log.counter_value
          last_request = r
          if (next_qs_counter_incrementation <= sum_qs_count_for_request)
            break
          end
       end
    }
    return last_request
  end


  #                # 
  # Stream reviews #
  #                #  
  
  def get_stream_review
    last_reviews = Array.new
    self.review_types.each {|rt|
      last_review = StreamReview.first(:conditions => ["stream_id = ? and review_type_id = ?",self.id ,rt.id], :order => "created_at DESC")
      if last_review != nil
        last_reviews.push(last_review)
      end
    }
    return last_reviews
  end

  def get_last_update_review
    last_review = StreamReview.first(:conditions => ["stream_id = ?",self.id], :order => "created_at DESC")
    return last_review
  end
  
  
  #                # 
  # Static methods #
  #                #  

  def self.find_with_workstream(workstreamParam)
    ws = Workstream.first(:conditions => ["name = ?",workstreamParam])
    stream = Stream.first(:conditions => ["workstream_id = ?",ws.id.to_s])
    return stream
  end
  
end
