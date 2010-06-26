class WelcomeController < ApplicationController

  def index
    @report = Report.new(Request.all)
    @last = Request.find(:all, :limit=>5, :order=>"updated_at desc")
    @sdp = Request.find(:all, :conditions=>["sdp='No' and start_date < ? and resolution='in progress' and workstream in ('EDS','EDG','EI','EM','EDC')", Date.today()+8], :order=>"start_date")
    @not_assigned = Request.find(:all, :conditions=>["status!='assigned' and status!='cancelled' and start_date < ? and workstream in ('EDS','EDG','EI','EM','EDC')", Date.today()+15], :order=>"start_date")
  end

  def upload
    post = params[:upload]
    name =  post['datafile'].original_filename
    directory = "public/data"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(post['datafile'].read) }
    report = CvsReport.new(path)
    report.parse
    # transform the Report into a Request
      report.requests.each { |req|
        # get the id if it exist, else create it
        r = Request.find_by_request_id(req.id)
        r = Request.create(:request_id=>req.id) if not r
        r.update_attributes(req.to_hash) # and it updates only the attributes that have changed !
        r.save
        }
    redirect_to :action=>:index
  end
  
  def workload_schedule
  end

private

=begin
  def init
    @report = CvsReport.new('/home/mick/DL/mfaivremacon.csv')
    #@report = Report.new('D:\DL\mfaivremacon.csv')
    @report.parse
  end  
=end

end
