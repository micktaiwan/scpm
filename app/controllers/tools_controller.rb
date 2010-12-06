class ToolsController < ApplicationController

  include WelcomeHelper

  def index
  end

  def stats_open_projects
    today     = Date.today()
    month     = 6
    year      = 2010
    @xml = Builder::XmlMarkup.new(:indent => 1)
    @stats = []
    begin
      d =  Date.new(year,month,1) - 1.day
      requests = Request.find(:all, :conditions=>"date_submitted < '#{d.to_s}' and status!='to be validated' and status!='cancelled'")
      a = requests.size
      b = requests.map{|r| r.project_name}.uniq.size # work also with a simple group by clause
      c = requests.map{|r| get_workpackage_name_from_summary(r.summary, '')}.uniq.size
      @stats << [d, a,b,c]

      month += 1
      if month > 12
        month = 1
        year += 1
      end
    rescue Exception => e
      render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
      return
    end while year < today.cwyear or (year == today.cwyear and month <= today.month)

    #headers['Content-Type'] = "application/vnd.ms-excel"
    #headers['Content-Disposition'] = 'attachment; filename="Stats.xls"'
    #headers['Cache-Control'] = ''
    render(:layout=>false)
  end

end

