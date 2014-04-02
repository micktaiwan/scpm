class WelcomeController < ApplicationController

  if APP_CONFIG['project_name']=='EISQ'
    layout 'tools'
  else
    layout 'mp_tools'
  end
  before_filter :require_login

  def index
    @report     = Report.new(Request.all)
    @report_without_cancelled_and_removed   = Report.new(Request.find(:all, :conditions=>"status!='removed' and status!='cancelled'"))
    @report2011 = Report.new(Request.find(:all, :conditions=>"status!='removed' and status!='cancelled' and PO != '2010'"))
    #@sdp = Request.find(:all, :conditions=>["sdp!='Yes' and start_date < ? and status='assigned'", Date.today()+8], :order=>"start_date")
    #@not_assigned = Request.find(:all, :conditions=>["(status='new' or status='acknowledged') and start_date < ?", Date.today()+15], :order=>"start_date")
    @sdp_cancelled    = Request.find(:all, :conditions=>["sdp='Yes' and status='cancelled'", Date.today()], :order=>"milestone_date")
    @not_performed    = Request.find(:all, :conditions=>["resolution='ended' and status!='performed' and status!='closed' and status!='cancelled'", Date.today()], :order=>"milestone_date")
    #@next_milestones =  Request.find(:all, :conditions=>["resolution != 'ended' and  (milestone_date !='' and milestone_date <= ?)", Date.today()+10], :order=>"milestone_date")
    get_anomalies
  end

  def update
    #last request update
    last_request_update = Request.find(:first, :select=>"updated_at", :order=>"updated_at desc")
    if last_request_update != nil  
      @last_update = last_request_update.updated_at
    else
      @last_update = nil
    end
    #last sdp update
    last_sdp_phase = SDPPhase.find(:first,:select=>"updated_at", :order=>'updated_at desc')
    if last_sdp_phase != nil
      @last_sdp_update = last_sdp_phase.updated_at
    else
      @last_sdp_update = nil
    end
  end

  def upload
    post      = params[:upload]
    name      =  post['datafile'].original_filename
    directory = "public/data"
    path      = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(post['datafile'].read) }
    report    = CvsReport.new(path)
    begin
      report.parse

      # transform the Report into a Request
      report.requests.each { |req|
        # get the id if it exist, else create it
        r = Request.find_by_request_id(req.id)
        r = Request.create(:request_id=>req.id) if not r
        r.update_attributes(req.to_hash) # and it updates only the attributes that have changed !
        #r.deploy_checklists if r.status == 'assigned' and r.status_changed?
        r.save

        # Create or update the counter log of this request
        if WORKPACKAGE_COUNTERS.include?(r.work_package[0..6])
          r.update_ticket_counters
        end
      }
      SDPTask.format_stats_by_type()
      redirect_to '/projects/import'
    rescue Exception => e
      render(:text=>e)
    end

  end

  def workload_schedule
    @requests = Request.find(:all, :conditions=>["status!='feedback' and status!='cancelled' and status!='removed' and (start_date!='' or milestone_date!='')"]).sort_by { |r| r.gantt_start_date}
    @resources = Person.all.collect { |r| r.rmt_user}.uniq.sort
    response.headers['Content-Type'] = 'text/xml'
    response.headers['Content-Disposition'] = 'attachment; filename=workload.gan'
    render(:layout=>false)
  end

  def reminders
    @all = Request.all
    get_anomalies
	  @rmt_users = Person.find(:all, :conditions=>"is_supervisor=0 and has_left=0 and is_transverse=0", :order=>"name")
  end

  def cut
    session[:request_cut] = params[:id]
    session[:cut]         = nil
    session[:action_cut]  = nil
    session[:status_cut]  = nil
    render(:nothing => true)
  end

private

  def get_anomalies
    @not_started          = Request.find(:all, :conditions=>["start_date != '' and start_date <= ? and resolution!='in progress' and resolution!='ended' and resolution!='aborted' and status!='cancelled'  and status!='removed' and status!='to be validated'", Date.today()], :order=>"start_date")
    @null_start_date      = Request.find(:all, :conditions=>["start_date = '' and status='assigned'"], :order=>"start_date")
    @null_milestones      = Request.find(:all, :conditions=>["milestone_date = '' and status != 'cancelled' and resolution='in progress' and milestone != 'N/A'"], :order=>"start_date")
    @past_milestones      = Request.find(:all, :conditions=>["((actual_m_date != '' and actual_m_date < ?) or (actual_m_date = '' and milestone_date != '' and milestone_date < ?)) and resolution!='ended' and resolution!='aborted' and status != 'cancelled' and status != 'removed'", Date.today(), Date.today()], :order=>"milestone_date")
    @ended_without_amdate = Request.find(:all, :conditions=>["status !='cancelled' and resolution='ended' and actual_m_date=''"], :order=>"start_date")
    @ci_projects_all = CiProject.find(:all)
    @ci_projects_late = CiProject.find(:all, :conditions=>["(status='Accepted' or status='Assigned') and ((sqli_validation_date_review < Now()) or (airbus_validation_date_review < Now()) or (deployment_date_review < Now()))"], :order=>"sqli_validation_date_review desc")
    @ci_projects_late_objective = CiProject.find(:all, :conditions=>["(status='Accepted' or status='Assigned') and ((sqli_validation_date_objective < Now()) or (airbus_validation_date_objective < Now()) or (deployment_date_objective < Now()))"], :order=>"sqli_validation_date_objective desc")
    @ci_projects_assigned_without_kickoff = CiProject.find(:all, :conditions=>["kick_off_date IS NULL and assigned_to IS NOT NULL"], :order=>"sqli_validation_date_review desc")
    
  end

=begin
  def init
    @report = CvsReport.new('/home/mick/DL/mfaivremacon.csv')
    #@report = Report.new('D:\DL\mfaivremacon.csv')
    @report.parse
  end
=end

end
