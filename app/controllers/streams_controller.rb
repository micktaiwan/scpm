class StreamsController < ApplicationController
  layout "general"
  include WelcomeHelper
  
  # GENERAL ACTIONS
  def index
  end
  
  def show
    id = params['id']
    @stream = Stream.find(id)
  end
  
  def edit
    id = params['id']
    @stream = Stream.find(id)
    @supervisors = Person.find(:all, :conditions=>"is_supervisor=1", :order=>"name asc")
  end
  
  def update
    stream = Stream.find(params[:id])
    stream.update_attributes(params[:stream])
    redirect_to :action=>:show_stream_informations, :id=>stream.id
  end
  
  def show_stream_projects
    id            = params['id']
    @stream       = Stream.find(id)
    @creationError = params['creationError']    
    
    # @projects = Project.find(:all,:conditions => ["workstream = ? 
    #                                               and is_running = 1 
    #                                               and project_id is null 
    #                                               and qr_qwr_id IS NOT NULL 
    #                                               and qr_qwr_id != 0 
    #                                               and is_qr_qwr = 1", Workstream.find(@stream.workstream).name])
    @projects = Project.find(:all,:conditions => ["workstream = ? 
                                                  and is_running = 1 
                                                  and project_id is null", Workstream.find(@stream.workstream).name], :order=>"name")
  end
  
  def show_stream_informations
    id            = params['id']
    @stream       = Stream.find(id)
    
    # Get all review types
    @reviewTypes = ReviewType.find(:all)
  end

  def add_request
    stream_id          = params['id']
    request_id         = params['request_id']
    if (request_id.length == 7)
      request            = Request.first(:conditions => ["request_id = ?",request_id])
      request.stream_id  = stream_id
      request.project_id = nil
      request.is_stream  = 1
      request.save
    end

    redirect_to :controller=>"streams", :action=>:show_stream_informations, :id=>stream_id
  end

  def remove_request
    stream_id          = params['id']
    request_id         = params['request_id']
    request            = Request.first(:conditions => ["request_id = ?", request_id])
    request.stream_id  = nil
    request.is_stream  = 1
    request.save 
    redirect_to :controller=>"streams", :action=>:show_stream_informations, :id=>stream_id
  end

  def show_stream_review
    id              = params['id']
    review_type_id  = params['type']
    @stream         = Stream.find(id) 
    @review_type    = ReviewType.find(review_type_id)
    
    reviews = StreamReview.find(:all,:conditions => ["stream_id = ? and review_type_id = ?",@stream.id, review_type_id],:order => "created_at DESC")
    @last_review = reviews[0]
    
    @old_reviews = Array.new
    review_index = 0;
    reviews.each do |review|
      @old_reviews << review if review_index != 0
      review_index += 1
    end
  end
  
  def show_stream_risks
    id = params['id']
    @stream         = Stream.find(id) 
    
  end
  
  def show_informations_by_qr_qwr
    streamId                = params['id']
    @stream                 = Stream.find(streamId)
    @informations_by_qr_qwr = Array.new
    # Get all QR QWR.EACH
    Person.find(:all,:include => [:person_roles,:roles], :conditions=>["roles.name = 'QR'"], :order=>"people.name asc").each do |qr|    
      # Params
      qr_qwr_data         = Hash.new
      qr_qwr_data["name"] = qr.name

      # Get number of project in this stream
      project_list              = Project.find(:all,:conditions=>["workstream = ? and is_running = 1 and is_qr_qwr IS NOT NULL and qr_qwr_id = ?", Workstream.find(@stream.workstream).name, qr.id.to_s])
      qr_qwr_data["nbProjects"] = project_list.count

      if qr_qwr_data["nbProjects"] > 0
        project_list.each do |project|
          if project.is_running
            # Get nb of QS prev total
            qr_qwr_data["total_qs_prev"]     = qr_qwr_data["total_qs_prev"].to_i     + project.calcul_qs_previsional
            # Get nb of Spider Prev total
            qr_qwr_data["total_spider_prev"] = qr_qwr_data["total_spider_prev"].to_i + project.calcul_spider_previsional
          end
        end


        # Get x/y for qs (alert managed in view)
        qr_qwr_data["qs_x"]       = HistoryCounter.find(:all,:include => [:request], :conditions => ["author_id = ? and history_counters.stream_id = ? and concerned_status_id IS NOT NULL and concerned_spider_id IS NULL and requests.assigned_to = ?",qr.id.to_s, @stream.id.to_s, qr.rmt_user]).count
        qr_qwr_data["qs_x_ghost"] = HistoryCounter.find(:all,:include => [:request], :conditions => ["author_id = ? and history_counters.stream_id = ? and concerned_status_id IS NOT NULL and concerned_spider_id IS NULL and requests.assigned_to != ?",qr.id.to_s, @stream.id.to_s, qr.rmt_user]).count
        qr_qwr_data["qs_y"]     = 0 
        request_qs_array        = Array.new

        Request.find(:all,:include=>[:counter_log],:conditions => ["work_package = ? and assigned_to = ? and is_stream = 'Yes' and stream_id = ? and counter_logs.validity = 1", WORKPACKAGE_QS_RMT_NAME, qr.rmt_user, @stream.id]).each do |req|
          qr_qwr_data["qs_y"] = qr_qwr_data["qs_y"].to_i + req.counter_log.counter_value.to_i
          request_qs_array    << req.id
        end
        qr_qwr_data["qs_consumed_by_other_author"] = HistoryCounter.find(:all,
          :conditions => ["author_id != ? and concerned_status_id IS NOT NULL and concerned_spider_id IS NULL and request_id IN (?)", qr.id.to_s, request_qs_array.join(',').to_s]).count


        # Get x/y for spider (alert managed in view)
        qr_qwr_data["spider_x"]       = HistoryCounter.find(:all,:include => [:request],:conditions => ["author_id = ? and history_counters.stream_id = ? and concerned_status_id IS NULL and concerned_spider_id IS NOT NULL and requests.assigned_to = ?",qr.id.to_s, @stream.id.to_s, qr.rmt_user]).count
        qr_qwr_data["spider_x_ghost"] = HistoryCounter.find(:all,:include => [:request],:conditions => ["author_id = ? and history_counters.stream_id = ? and concerned_status_id IS NULL and concerned_spider_id IS NOT NULL and requests.assigned_to != ?",qr.id.to_s, @stream.id.to_s, qr.rmt_user]).count
        qr_qwr_data["spider_y"] = 0 
        request_spider_array    = Array.new

        Request.find(:all,:include=>[:counter_log],:conditions => ["work_package = ? and assigned_to = ? and is_stream = 'Yes' and stream_id = ? and counter_logs.validity = 1", WORKPACKAGE_SPIDERS_RMT_NAME, qr.rmt_user, @stream.id]).each do |req|
          qr_qwr_data["spider_y"] = qr_qwr_data["spider_y"].to_i + req.counter_log.counter_value.to_i
          request_spider_array    << req.id
        end
        qr_qwr_data["spider_consumed_by_other_author"] = HistoryCounter.find(:all,
          :conditions => ["author_id != ? and concerned_status_id IS NULL and concerned_spider_id IS NOT NULL and request_id IN (?)", qr.id.to_s, request_spider_array.join(',').to_s]).count

        # Compare
        qr_qwr_data["qs_comp"]     = (qr_qwr_data["qs_y"].to_i     - qr_qwr_data["qs_x"].to_i)      - qr_qwr_data["total_qs_prev"].to_i
        qr_qwr_data["spider_comp"] = (qr_qwr_data["spider_y"].to_i - qr_qwr_data["spider-_x"].to_i) - qr_qwr_data["total_spider_prev"].to_i

        @informations_by_qr_qwr << qr_qwr_data
      end
    end

  end

  # link a request to a Stream, based on request workstream
  def link
    # PARAMS
    request_id        = params[:id]
    request           = Request.find(request_id)
    project_name      = request.project_name
    workpackage_name  = request.workpackage_name
    brn               = request.brn
    workstream        = request.workstream
    str               = "saved"
    
    # STREAM
    stream = Stream.find_with_workstream(workstream)
    if not stream
      render(:text=>"Stream not found")
    end
    # UPDATE REQUEST
    request.stream_id = stream.id
    request.save
    
    # Commented because a new page was created to link previous history to new request, see in tools.
    # CHECK HISTORY_COUNT WITHOUT REQUEST
    # if request.counter_log.validity
    #   history_count_no_request = nil
    #   if (WORKPACKAGE_QS == request.work_package[0..6])
    #     history_count_no_request = HistoryCounter.find(:all, :conditions=>["stream_id = ? and request_id IS NULL and concerned_status_id IS NOT NULL",stream.id])
    #   elsif (WORKPACKAGE_SPIDERS == request.work_package[0..6])
    #     history_count_no_request = HistoryCounter.find(:all, :conditions=>["stream_id = ? and request_id IS NULL and concerned_spider_id IS NOT NULL",stream.id])
    #   end
      
    #   if (WORKPACKAGE_COUNTERS.include?(request.work_package[0..6]))
    #     count       = 0
    #     total_count = CounterBaseValue.first(:conditions => ["complexity = ? and sdp_iteration = ? and workpackage = ?",request.complexity,request.sdpiteration,request.work_package]).value
    #     history_count_no_request.each do |hc_no_req|
    #       if count < total_count
    #         hc_no_req.request_id = request.id
    #         hc_no_req.save
    #         count = count + 1
    #       end
    #     end
    #     # TEXT RESULT
    #     if count > 0
    #       str = str+" and "+count.to_s+" ticket already used."
    #     end
        
    #   end
    # end
    
    render(:text=>str)
  end

  # Link old counters with new requests
  def link_old_counter
    # PARAMs
    history_counter_id = params[:history_counter_id]
    request_id         = params[:request_id]
    history_counter    = HistoryCounter.find(history_counter_id)
    request            = Request.find(request_id)

    history_counter.request_id = request.id
    history_counter.save
    
    #render(:text=>"Saved")
    redirect_to :controller=>"tools", :action=>:show_counter_history

  end
  
  # FORM INFORMATIONS - UPDATE
  def update_stream_review_types
    
    rtSelected = params[:reviewTypeForm] #ReviewTypes selected in the form
    stream = Stream.find(params[:id])
    streamRt = stream.review_types #ReviewTypes already added to stream
    
    # For each reviewType
    ReviewType.find(:all).each do |rt|   
      # If current rt is selected in the form and not already added to stream
      if rtSelected.include?(rt.id.to_s) and !streamRt.include?(rt)
        # ADD / CREATE
        srt = StreamReviewType.create
        srt.stream_id = stream.id
        srt.review_type_id = rt.id
        srt.save
      # If current RT is not selected in form and previously added to stream
      elsif !rtSelected.include?(rt.id.to_s) and streamRt.include?(rt)
        # DELETE
        srt = StreamReviewType.first(:conditions=>["stream_id = ? and review_type_id = ?",stream.id.to_s,rt.id.to_s])
        srt.destroy
      end
    end
    redirect_to :action=>:show_stream_informations, :id=>stream.id
  end
  
  
  # FORM REVIEW - EDIT/UPDATE
  def edit_review
    id = params['id']
    @review = StreamReview.find(id)
  end
  
  def update_review
    review = StreamReview.find(params[:id])
    review.text = params[:review][:text]
    review.save
    review.stream.calculate_diffs(review.review_type_id)
    redirect_to :action=>:show_stream_review, :id=>review.stream_id, :type=>review.review_type_id
  end
  
  # FORM REVIEW - CREATE/REVIEW
  def add_review_form
    id = params['id']
    type = params['type']
    last_review = StreamReview.first(:conditions => ["stream_id = ? and review_type_id = ?",id ,type], :order => "created_at DESC")
    @review = StreamReview.new
    @review.stream_id = id 
    if(last_review)   
      @review.text = last_review.text
    end
    @review.review_type_id = type
  end
  
  def create_review
    review                = StreamReview.create(params[:review])
    review.stream_id      = params[:review][:stream_id]
    review.review_type_id = params[:review][:review_type_id]
    review.author_id      = current_user.id
    review.save
    review.stream.calculate_diffs(review.review_type_id)
    redirect_to :action=>:show_stream_review, :id=>review.stream_id, :type=>review.review_type_id
  end
  
  def cut_review
  end 
  
  def destroy_review
    StreamReview.find(params[:id].to_i).destroy
    render(:nothing=>true)
  end
  
  
  # List streams
  
  def mark_as_read
    s           = Stream.find(params[:id])
    s.read_date = Time.now
    s.save
    render(:nothing=>true)
  end

  # List projects
  
  def create_project
    id                = params[:id]
    workstream        = Stream.find(id).workstream
    summaryParam      = params[:summary]
    project_name      = params[:project_name]
    
    resultRegex = summaryParam.scan(/\[(.*?)\]/)
    if ((resultRegex.count == 3) && (resultRegex[0].to_s.length > 0) && (resultRegex[1].to_s.length > 0) && (project_name.length > 0))
      
      summary           = "[" + resultRegex[0].to_s + "][" + resultRegex[1].to_s + "]["+resultRegex[2].to_s+"]"
      workpackage_name  = get_workpackage_name_from_summary(summary, project_name)
      brn               = summary.split(/\[([^\]]*)\]/)[5]
      
      project = Project.find_by_name(project_name)
      if not project
        project = Project.create(:name=>project_name)
        project.workstream        = workstream.name
        project.lifecycle_object  = Lifecycle.first
        project.save
      end

      wp = Project.find_by_name(workpackage_name, :conditions=>["project_id=?",project.id])
      if not wp
        wp = Project.create(:name=>workpackage_name)
        wp.workstream       = workstream.name
        wp.brn              = brn
        wp.lifecycle_object = Lifecycle.first
        wp.project_id       = project.id
        wp.save
      end

      project.add_responsible_from_rmt_user(current_user.rmt_user) if current_user != nil
      redirect_to :action=>:show_stream_projects, :id=>id, :creationError=>false
    else
      redirect_to :action=>:show_stream_projects, :id=>id, :creationError=>true
    end
  end


end
