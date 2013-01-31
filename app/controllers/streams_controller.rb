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
  
  def show_stream_projects
    id = params['id']
    @stream = Stream.find(id)
    @projects = Project.find(:all,:conditions => ["workstream = ?", Workstream.find(@stream.workstream).name])
  end
  
  def show_stream_informations
    id = params['id']
    @stream = Stream.find(id)
    
    # Get all review types
    @reviewTypes = ReviewType.find(:all)
    
    # Get all Requests
    # @requests = Request.find(:all,:conditions => ["stream_id = ?", id])
  end
  
  def show_stream_review
    id = params['id']
    @review_type = params['type']
    @stream = Stream.find(id) 
    
    reviews = StreamReview.find(:all,:conditions => ["stream_id = ? and review_type_id = ?",@stream.id, @review_type],:order => "created_at DESC")
    @last_review = reviews[0]
    
    @old_reviews = Array.new
    review_index = 0;
    reviews.each do |review|
      @old_reviews << review if review_index != 0
      review_index += 1
    end
  end
  
  # link a request to a Stream, based on request workstream
  def link
    request_id        = params[:id]
    request           = Request.find(request_id)
    project_name      = request.project_name
    workpackage_name  = request.workpackage_name
    brn               = request.brn
    workstream        = request.workstream
    
    stream = Stream.find_with_workstream(workstream)
    if not stream
    render(:text=>"Stream not found")
    end

    request.stream_id = stream.id
    request.save
    render(:text=>"saved")
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
    redirect_to :action=>:show, :id=>review.stream_id
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
    redirect_to :action=>:show, :id=>review.stream_id
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
    summary           = params[:summary]
    project_name      = params[:project_name]
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
    
    redirect_to :action=>:show, :id=>id
    
  end


end
