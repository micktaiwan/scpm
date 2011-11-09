class RequirementsController < ApplicationController

  layout 'tools'

  def index
    select_reqs
  end

  def new
    @req    = Requirement.new
    get_attributes
  end

  def create
    @req = Requirement.new(params[:req])
    @req.status_date = Date.today()
    @req.person_id = current_user.id
    @errors = nil
    @errors = @req.errors.full_messages.join("\n") and return if not @req.save
    redirect_to('/requirements')
  end

private

  def get_attributes
    @cats   = ReqCategory.all.map {|p| [ p.label, p.id ] }
    @waves  = ReqWave.all.map {|p| [ p.name, p.id ] }
    @status = [['Proposed', 100], ['Reviewed', 200], ['Approved by SQLI', 300],
     ['Conception in progress', 400], ['Validated by SQLI', 500], ['Refused by customer', 600],
     ['Accepted by customer', 700], ['Realisation in progress', 800], ['Deployed', 900],
     ['Superseded', 1000], ['Deleted', 1100]]
  end

  def select_reqs()#wave_id=nil)
    #wave_id = @d_id if not doc_id
    @reqs = Requirement.find(:all)
    #@reqs = do_sort(@reqs)
  end

  def do_sort(reqs)
    return
    case session[:req_sort]
    when nil,'', 'prio'
      reqs.sort_by { |r| [(r.priority||0),(r.status||0),r.id] }
    when 'status'
      reqs.sort_by { |r| [(r.status||0),(r.priority||0),r.id] }
    when 'cat'
      reqs.sort_by { |r| [(r.category||0),(r.priority||0),r.id] }
    when 'id'
      reqs.sort_by { |r| r.id }
    end
  end

end

