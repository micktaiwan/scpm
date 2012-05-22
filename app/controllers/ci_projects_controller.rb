require 'lib/csv_ci'
class CiProjectsController < ApplicationController

	layout 'ci'

	def index
  	redirect_to :action=>:mine
	end

  def mine
    verif
    @projects = CiProject.find(:all, :conditions=>["assigned_to=?", current_user.rmt_user]).sort_by {|p| [p.order]}
  end

  def all
    verif
    @projects = CiProject.find(:all).sort_by {|p| [p.order||0, p.assigned_to||'']}
  end

  def late
    @toassign = CiProject.find(:all, :conditions=>"assigned_to='' and status!='Closed' and status!='Delivered' and status!='Rejected'", :order=>"sqli_validation_date_review desc")
    @sqli     = CiProject.find(:all, :conditions=>"status='Accepted' or status='Assigned'", :order=>"sqli_validation_date_review desc")
    @todeploy = CiProject.find(:all, :conditions=>"status='Validated'", :order=>"sqli_validation_date_review desc")
    @airbus   = CiProject.find(:all, :conditions=>"status='Verified'", :order=>"sqli_validation_date_review desc")
  end

  def verif
    CiProject.all.each { |p| 
      p.sqli_validation_date_review   = p.sqli_validation_date_objective if !p.sqli_validation_date_review
      p.airbus_validation_date_review = p.airbus_validation_date_objective if !p.airbus_validation_date_review
      p.deployment_date_review        = p.deployment_date_objective if !p.deployment_date_review
      p.save
    }
  end

  def report
    @sqli     = CiProject.find(:all, :conditions=>"deployment='External' and visibility='Public' and (status='Accepted' or status='Assigned')", :order=>"sqli_validation_date_review")
    @airbus   = CiProject.find(:all, :conditions=>"deployment='External' and visibility='Public' and (status='Verified')", :order=>"airbus_validation_date_review")
  end

  def do_upload
    post = params[:upload]
    redirect_to '/ci_projects/index' and return if post.nil? or post['datafile'].nil?    
    name =  post['datafile'].original_filename
    directory = "public/data"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(post['datafile'].read) }
    report = CsvCiReport.new(path)
    report.parse
    # transform the Report into a CiProject
    report.projects.each { |p|
      # get the id if it exist, else create it
      ci = CiProject.find_by_external_id(p.external_id)
      ci = CiProject.create(:external_id=>p.exterbal_id) if not ci
      ci.update_attributes(p.to_hash) # and it updates only the attributes that have changed !
      ci.save
      }
    redirect_to '/ci_projects/index'
  end

  def edit
    id = params[:id]
    @project = CiProject.find(id)
  end

  def update
    p = CiProject.find(params[:id])
    p.update_attributes(params[:project])
    redirect_to "/ci_projects/index"
  end
end
