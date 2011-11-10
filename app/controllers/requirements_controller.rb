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

  def edit
    @req    = Requirement.find(params[:id])
    get_attributes
  end

  def update
    id = params[:id]
    @req = Requirement.find(id)
    @req.person_id = current_user.id
    @req.status_date = Date.today() if params[:req][:status].to_i != @req.status
    if @req.update_attributes(params[:req]) # do a save
      redirect_to "/requirements"
    else
      render :action => 'edit'
    end
  end

  # generate an Excel file with reqs
  def excel
    begin
      @xml = Builder::XmlMarkup.new(:indent => 1)
      select_reqs

      headers['Content-Type']         = "application/vnd.ms-excel"
      headers['Content-Disposition']  = 'attachment; filename="Requirements.xls"'
      headers['Cache-Control']        = ''
      render(:layout=>false)
    rescue Exception => e
      render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
    end
  end

private

  def get_attributes
    @cats   = ReqCategory.all.map {|p| [ p.label, p.id ] }
    @waves  = ReqWave.all.map {|p| [ p.name, p.id ] }
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

