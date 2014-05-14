class Stream < ActiveRecord::Base
  has_many    :requests,          :dependent=>:nullify
  has_many    :stream_reviews,    :dependent => :destroy, :order=>"created_at desc"
  belongs_to  :workstream
  belongs_to  :supervisor, :class_name=>"Person", :foreign_key=>"supervisor_id"
  has_many    :stream_review_types
  has_many    :review_types, :through=>:stream_review_types
  has_many    :risks

  # give a list of corresponding requests QR
  def assignees
    rv = []
    requests.each { |r|
      if r.assigned_to != ''
        person = Person.find_by_rmt_user(r.assigned_to)
      else
        person = nil
      end
      name = person ? person.name : r.assigned_to
      name += " (#{r.work_package})"
      rv << name if not rv.include?(name)
      }
    rv
  end

  def qs_requests_sorted_by_counters
    self.requests.sort_by { |r|  [-get_consumed_qs_counter_for_request(r), r.start_date] }
  end

  def spider_requests_sorted_by_counters
    self.requests.sort_by { |r|  [-get_consumed_spider_counter_for_request(r), r.start_date] }
  end

  # Risks
  def suggested_status
    rv = 1
    self.risks.each { |r|
      if (r.is_quality == 1)
        rv = 2 if rv < 2 and (r.isMedium? or r.isHigh?)
        rv = 3 if rv < 3 and r.isCritical?
      end
    }
    rv
  end

  def get_total_green_projects
      return Project.count(:all,:conditions => ["workstream = ? and last_status = '1'", Workstream.find(self.workstream).name])
  end

  def get_total_amber_projects 
      return Project.count(:all,:conditions => ["workstream = ? and last_status = '2'", Workstream.find(self.workstream).name])
  end

  def get_total_red_projects
      return Project.count(:all,:conditions => ["workstream = ? and last_status = '3'", Workstream.find(self.workstream).name])
  end

  #                         #
  # Consumed tickets count  #
  #                         #

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

  def get_consumed_qs_count_for_user(user)
    historyCounters = HistoryCounter.find(:all,:include => [:request], :conditions => ["author_id = ? and history_counters.stream_id = ? and concerned_status_id IS NOT NULL and history_counters.request_id IS NOT NULL and requests.assigned_to = ?", user.id, self.id, user.rmt_user])
    return historyCounters.count
  end

  def get_consumed_spider_count_for_user(user)
    historyCounters = HistoryCounter.find(:all,:include => [:request], :conditions => ["author_id = ? and history_counters.stream_id = ? and concerned_spider_id IS NOT NULL and history_counters.request_id IS NOT NULL and requests.assigned_to = ?", user.id, self.id, user.rmt_user])
    return historyCounters.count
  end

  def get_consumed_qs_counter_for_request(request)
    historyCounters = HistoryCounter.find(:all,:conditions => ["request_id = ? and concerned_status_id IS NOT NULL", request.id])
    return historyCounters.count
  end

  def get_consumed_spider_counter_for_request(request)
    historyCounters = HistoryCounter.find(:all,:conditions => ["request_id = ? and concerned_spider_id IS NOT NULL", request.id])
    return historyCounters.count
  end


  #               #
  # Total tickets #
  #               #

  def get_qs_counter
    total = 0
    self.requests.sort_by{|r| r.start_date }.each { |r|
      if ((WORKPACKAGE_QS == r.work_package[0..6]) and (r.counter_log) and (r.counter_log.validity))
         total = total + r.counter_log.counter_value
      end
    }
    return total
  end

  def get_spider_counter
    total = 0
    self.requests.sort_by{|r| r.start_date }.each { |r|
      if ((WORKPACKAGE_SPIDERS == r.work_package[0..6]) and (r.counter_log) and (r.counter_log.validity))
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
    counter_request = self.get_current_spider_counter_request(author)

    newHistoryCounter = HistoryCounter.new
    newHistoryCounter.stream_id = self.id
    newHistoryCounter.author_id = author.id
    newHistoryCounter.concerned_spider_id = spider.id
    newHistoryCounter.action_date = DateTime.current

    if counter_request
      request_id = counter_request.id
      if request_id
        newHistoryCounter.request_id = request_id
      end
    end

    newHistoryCounter.save
  end

  def set_qs_history_counter(author,status)
    counter_request = self.get_current_qs_counter_request(author)

    newHistoryCounter = HistoryCounter.new
    newHistoryCounter.stream_id = self.id
    newHistoryCounter.author_id = author.id
    newHistoryCounter.concerned_status_id = status.id
    newHistoryCounter.action_date = DateTime.current

    if counter_request
      request_id = counter_request.id
      if request_id
        newHistoryCounter.request_id = request_id
      end
    end

    newHistoryCounter.save
  end

  #                                                   #
  # History ticket destroy                            #
  #                                                   #
  def delete_spider_history_counter(author,spider)
    # Current history counter
    currentHistoryCounter = HistoryCounter.find(:first, :conditions=>["concerned_spider_id = ?", spider.id.to_s])
    
    # Le last doit se baser sur la date mais uassi la request (exemlpe du cas qui pose pb là : On fait deux supp, ça change deux fois la request du même ticket)
    lastHistoryCounter    = HistoryCounter.find(:last, 
      :include => :request, 
      :conditions=> ["author_id = ? and history_counters.stream_id = ? and history_counters.request_id IS NOT NULL and concerned_spider_id IS NOT NULL", author.id, self.id], 
      :order=>"requests.start_date asc, history_counters.created_at asc")

    if lastHistoryCounter != nil
      lastHistoryCounter.request_id = currentHistoryCounter.request_id
      lastHistoryCounter.save
    end

    currentHistoryCounter.delete
  end

  #                                                   #
  # Retrieve the current Request (1.6.4 / 1.6.5) used #
  #                                                   #

  # Find the "Counter Request" (valide) for the next incrementation of spider counter
  # For a stream, we can have multiple "Counter request" with multiple counter values.
  # This "counter request" will be order by date
  def get_current_spider_counter_request(author)
    sum_spider_count_for_request = 0
    last_request = nil
    found = false

    # loop on requests of this stream by date
    self.spider_requests_sorted_by_counters.each { |r|
      if ((WORKPACKAGE_SPIDERS == r.work_package[0..6]) and (r.counter_log) and (r.counter_log.validity) and (r.assigned_to == author.rmt_user))
        if (get_consumed_spider_counter_for_request(r) < r.counter_log.counter_value)
          last_request = r
          found = true
          break
        end
      end
    }

    if found
      return last_request
    end
    return nil
  end

  # Find the "Counter Request" (valide) for the next incrementation of spider counter
  # For a stream, we can have multiple "Counter request" with multiple counter values.
  # This "counter request" will be order by date
  def get_current_qs_counter_request(author)

    # loop on requests of this stream by date
    last_request = nil
    found = false
    self.qs_requests_sorted_by_counters.each { |r|
       if ((WORKPACKAGE_QS == r.work_package[0..6]) and (r.counter_log) and (r.counter_log.validity) and (r.assigned_to == author.rmt_user))
          if (get_consumed_qs_counter_for_request(r) < r.counter_log.counter_value)
            last_request = r
            found = true
            break
          end
       end
    }

    if found
      return last_request
    end
    return nil
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


  # set last test dif
  def calculate_diffs(review_type)
    reviews = StreamReview.find(:all,:conditions => ["stream_id = ? and review_type_id = ?",self.id ,review_type], :order => "created_at DESC")
    if reviews.size > 2
      reviews[0].text_diff = Differ.diff(reviews[0].text,reviews[1].text).to_s.split("\n").join("<br/>") if reviews[0].text and reviews[1].text
      reviews[0].save
    end
  end

  #                #
  # Static methods #
  #                #

  def self.find_with_workstream(workstreamParam)
    ws = Workstream.first(:conditions => ["name = ?",workstreamParam])
    #raise "can not find stream with name '#{workstreamParam}'"
    stream = Stream.first(:conditions => ["workstream_id = ?",ws.id.to_s])
    return stream
  end

end
