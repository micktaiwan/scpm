require 'lib/csv_ci'
class CiProjectsController < ApplicationController

	layout 'ci'

	def index
			@projects = CiProject.find(:all,:order=>"status, external_id")
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

end
