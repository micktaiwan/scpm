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
    
    @projects = Project.find(:all,:conditions => ["workstream = ? and is_running = 1", Workstream.find(@stream.workstream).name])
  end
  
  def show_stream_informations
    id            = params['id']
    @stream       = Stream.find(id)
    
    # Get all review types
    @reviewTypes = ReviewType.find(:all)
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
    
    # CHECK HISTORY_COUNT WITHOUT REQUEST
    history_count_no_request = nil
    if (WORKPACKAGE_QS == request.work_package[0..6])
      history_count_no_request = HistoryCounter.find(:all,
            :conditions=>["stream_id = ? and request_id IS NULL and concerned_status_id IS NOT NULL",stream.id])
    elsif (WORKPACKAGE_SPIDERS == request.work_package[0..6])
      history_count_no_request = HistoryCounter.find(:all,
            :conditions=>["stream_id = ? and request_id IS NULL and concerned_spider_id IS NOT NULL",stream.id])
    end
    
    if (WORKPACKAGE_COUNTERS.include?(request.work_package[0..6]))
      count = 0
      total_count = CounterBaseValue.first(
      :conditions => ["complexity = ? and sdp_iteration = ? and workpackage = ?",request.complexity,request.sdpiteration,request.work_package]).value
		
      history_count_no_request.each do |hc_no_req|
        if count < total_count
          hc_no_req.request_id = request.id
          hc_no_req.save
          count = count + 1
        end
      end
    
      # TEXT RESULT
      if count > 0
        str = str+" and "+count.to_s+" ticket already used."
      end
    end
    
    render(:text=>str)
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
    if ((resultRegex.count == 3) && (resultRegex[0].to_s.length > 0) && (resultRegex[1].to_s.length > 0) && (resultRegex[0].to_s == project_name.to_s))
      
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
