require 'rubygems'
require 'google_chart'
# http://badpopcorn.com/blog/2008/09/08/rails-google-charts-gchartrb/

class WorkloadsController < ApplicationController

  layout 'pdc'

  def index
    person_id      = params[:person_id]
    project_ids    = params[:project_ids]
    iterations_ids = params[:iterations_ids]
    session['workload_person_id'] = person_id if person_id
    session['workload_person_id'] = current_user.id if not session['workload_person_id']
    session['workload_person_id'] = params[:wl_person] if params[:wl_person]
    if project_ids
      if project_ids.class==Array
        session['workload_person_project_ids'] = project_ids # array of strings
      else
        session['workload_person_project_ids'] = [project_ids] # array with one string
      end
    else
        session['workload_person_project_ids'] = []
    end
    session['workload_persons_iterations'] = []
    if iterations_ids
      iterations_ids.each do |i|
        iteration       = Iteration.find(i)
        iteration_name  = iteration.name
        project_code    = iteration.project_code
        project_id      = iteration.project.id
        session['workload_persons_iterations'] << {:name=>iteration_name, :project_code=>project_code, :project_id=>project_id}
      end
    end
    @people = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0", :order=>"name").map {|p| ["#{p.name} (#{p.wl_lines.size} lines)", p.id]}
    @projects = Project.find(:all).map {|p| ["#{p.name} (#{p.wl_lines.size} persons)", p.id]}
    change_workload(session['workload_person_id'])
  end

  def change_workload(person_id=nil)
    person_id = params[:person_id] if !person_id
    session['workload_person_id'] = person_id
    @workload = Workload.new(person_id,session['workload_person_project_ids'], session['workload_persons_iterations'], {:hide_lines_with_no_workload => session['workload_hide_lines_with_no_workload'].to_s=='true'})
    
    @person   = @workload.person
    get_last_sdp_update
    get_suggested_requests(@workload)
    get_sdp_tasks(@workload)
    get_chart
    get_sdp_gain(@workload.person)
    get_backup_warnings(@workload.person)
    get_holiday_warning(@workload.person)
    get_unlinked_sdp_tasks(@workload)
  end

  def get_last_sdp_update
    @last_sdp_phase = SDPPhase.find(:first, :order=>'updated_at desc')
    if @last_sdp_phase != nil
      @last_sdp_update = @last_sdp_phase.updated_at
    else
      @last_sdp_update = nil
    end
  end

  def get_chart
    chart = GoogleChart::LineChart.new('1000x300', "#{@workload.person.name} workload", false)
    serie = @workload.percents.map{ |p| p[:precise] }
    return if serie.size == 0
    realmax     = serie.max
    high_limit  = 150.0
    max         = realmax > high_limit ? high_limit : realmax
    high_limit  = high_limit > max ? max : high_limit
    chart.data "non capped", serie, '0000ff'
    chart.axis :y, :range => [0,max], :font_size => 10, :alignment => :center
    chart.axis :x, :labels => @workload.months, :font_size => 10, :alignment => :center
    chart.shape_marker :circle, :color=>'3333ff', :data_set_index=>0, :data_point_index=>-1, :pixel_size=>7
    serie.each_with_index do |p,index|
      if p > high_limit
        chart.shape_marker :circle, :color=>'ff3333', :data_set_index=>0, :data_point_index=>index, :pixel_size=>8
      end
    end
    chart.range_marker :horizontal, :color=>'DDDDDD', :start_point=>97.0/max, :end_point=>103.0/max
    chart.show_legend = false
    @chart_url = chart.to_url({:chd=>"t:#{serie.join(',')}", :chds=>"0,#{high_limit}"})
  end

  def get_suggested_requests(wl)
    if !wl or !wl.person or wl.person.rmt_user == ""
      @suggested_requests = []
      return
    end
    request_ids   = wl.wl_lines.select {|l| l.request_id != nil}.map { |l| filled_number(l.request_id,7)}
    cond = ""
    cond = " and request_id not in (#{request_ids.join(',')})" if request_ids.size > 0
    @suggested_requests = Request.find(:all, :conditions => "assigned_to='#{wl.person.rmt_user}' and status!='closed' and status!='performed' and status!='cancelled' and status!='removed' and resolution!='ended' #{cond}", :order=>"project_name, summary")
    @suggested_requests = @suggested_requests.select { |r| r.sdp_tasks_remaining_sum > 0 }
  end

  def get_backup_warnings(person_id)

    currentWeek = wlweek(Date.today)
    nextWeek    = wlweek(Date.today+7.days)
    backups = WlBackup.find(:all, :conditions=>["backup_person_id = ? and (week = ? or week = ?)", person_id, currentWeek, nextWeek])

    @backup_holidays = []
    backups.each do |b|  
      # Load for holyday and concerned user (for the 14 next days)
      person_holiday_load = WlLoad.find(:all,
        :joins => 'JOIN wl_lines ON wl_lines.id = wl_loads.wl_line_id', 
        :conditions=>["wl_lines.person_id = ? and wl_lines.wl_type = ? and (wl_loads.week = ? or wl_loads.week = ?)", b.person.id.to_s, WL_LINE_HOLIDAYS, currentWeek, nextWeek])

      if person_holiday_load.count > 0
        load_total = 0

        # Calcul the number of day of holiday. If it's over the threshold, display the warning
        person_holiday_load.map { |wload| load_total += wload.wlload }
        if (load_total > APP_CONFIG['workload_holiday_threshold_before_backup'])
         @backup_holidays << b.person.name if !@backup_holidays.include?(b.person.name)
        end
      end

    end
  end

  def do_get_sdp_tasks()
    person_id = session['workload_person_id']
    p = Person.find(person_id)
    @sdp_tasks = SDPTask.find(:all, :conditions=>["collab=?", p.trigram], :order=>"title").map{|t| ["#{ActionController::Base.helpers.sanitize(t.title)} (#{t.remaining})", t.sdp_id]}
    render(:partial=>'sdp_task_options')
  end

  def get_sdp_tasks(wl,options = {})
    # if  wl.nil? 
      if wl.person.trigram == ""
        @sdp_tasks = []
        return
      end
      task_ids   = wl.wl_lines.map{|l| l.sdp_tasks.map{|l| l.sdp_id}}.select{|l| (l != [])}#wl.wl_lines.select {|l| l.sdp_task_id != nil}.map { |l| l.sdp_task_id}
      cond = ""
      cond = " and sdp_id not in (#{task_ids.join(',')})" if task_ids.size > 0
      @sdp_tasks = SDPTask.find(:all, :conditions=>["collab=? and request_id is null #{cond} and remaining > 0", wl.person.trigram], :order=>"title").map{|t| ["#{ActionController::Base.helpers.sanitize(t.title)} (#{t.assigned})", t.sdp_id]}
    # end
  end

  def get_unlinked_sdp_tasks(wl)
    # Directly linked wl<=> sdp
    task_ids   = wl.wl_lines.map{|l| l.sdp_tasks.map{|l| l.sdp_id}}.select{|l| (l != [])}
    cond = " and sdp_id not in (#{task_ids.join(',')})" if task_ids.size > 0
    @sdp_tasks_unlinked  = SDPTask.find(:all, :conditions => ["collab = ? AND request_id IS NULL #{cond} and remaining > 0", wl.person.trigram])
    # By requests
    wl_lines_id             = wl.wl_lines.map{ |l| l.request_id}
    @sdp_tasks_unlinked_req = SDPTask.find(:all, :conditions => ["collab = ? AND request_id IS NOT NULL AND request_id NOT IN (?) and remaining > 0", wl.person.trigram, wl_lines_id])

    # render :layout => false
  end

  def get_holiday_warning(person)
    @holiday_without_backup = false
    person_holiday_load = WlLoad.find(:all,
        :joins => 'JOIN wl_lines ON wl_lines.id = wl_loads.wl_line_id', 
        :conditions=>["wl_lines.person_id = ? and wl_lines.wl_type = ? and week >= ? and week < ? and wlload >= ?", person.id.to_s, WL_LINE_HOLIDAYS, wlweek(Date.today), wlweek(Date.today+8.weeks), APP_CONFIG['workload_holiday_threshold_before_backup']])
    person_holiday_load.each do |holiday|
      backups = WlBackup.find(:all, :conditions=>["person_id = ? and week = ?",person.id.to_s, holiday.week])
      if backups == nil or backups.size == 0
        @holiday_without_backup = true
        return
      end
    end

  end

  def get_sdp_gain(person)
    @balance = person.sdp_balance
    @sdp_logs = SdpLog.find(:all, :conditions=>["person_id=?", person.id], :order=>"`date` desc", :limit=>3).reverse
  end

  def consolidation
    @companies = Company.all.map {|p| ["#{p.name}", p.id]}
  end

  def refresh_conso
    @start_time = Time.now
    # find "to be validated" requests not in the workload
    already_in_the_workload = WlLine.all.select{|l| l.request and (l.request.status=='to be validated' or (l.request.status=='assigned' and l.request.resolution!='ended' and l.request.resolution!='aborted'))}.map{|l| l.request}
    @not_in_workload = (Request.find(:all,:conditions=>"status='to be validated' or (status='assigned' and resolution!='ended' and resolution!='aborted')") - already_in_the_workload).sort_by{|r| (r.project ? r.project.full_name : "")}
    # find the corresponding production days (minus 20% of gain)
    @not_in_workload_days = @not_in_workload.inject(0) { |sum, r| sum += r.workload2} * 0.80

    company_ids = params['company']
    company_ids = company_ids['company_ids'] if company_ids
    # FIXME: pass only a simple field....

    cond = ""
    cond += " and company_id in (#{company_ids})" if company_ids and company_ids!=''
    @people = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0 and is_transverse=0"+cond, :order=>"name")
    @transverse_people = Person.find(:all, :conditions=>"has_left=0 and is_transverse=1", :order=>"name").map{|p| p.name.split(" ")[0]}.join(", ")
    @workloads = []
    @total_days = 0
    @total_planned_days = 0
    @to_be_validated_in_wl_remaining_total = 0
    for p in @people
      w = Workload.new(p.id,session['workload_person_project_ids'],session['workload_persons_iterations'])
      @workloads << w
      @total_days += w.line_sums.inject(0) { |sum, (k,v)|
        sum += v[:remaining] == '' ? 0 : v[:remaining]
      }
      @total_planned_days += w.planned_total
      @to_be_validated_in_wl_remaining_total += w.to_be_validated_in_wl_remaining_total
      #break
    end
    @workloads = @workloads.sort_by {|w| [-w.person.is_virtual, w.next_month_percents, w.three_next_months_percents, w.person.name]}
    @totals       = []
    @cap_totals   = []
    @chart_totals       = []
    @chart_cap_totals   = []
    @avail_totals = []
    size          = @workloads.size
    if size == 0
      render :layout => false
      return
    end
    chart_size          = @workloads.select{|w| w.person.is_virtual==0}.size

    # to plan
    @totals << (@workloads.inject(0) { |sum,w| sum += w.remain_to_plan_days })
    @cap_totals << ''
    @avail_totals << ''
    # next 5 weeks
    @totals << (@workloads.inject(0) { |sum,w| sum += w.next_month_percents} / size).round
    @cap_totals << (@workloads.inject(0) { |sum,w| sum += cap(w.next_month_percents)} / size).round
    @avail_totals << ''
    # next 3 months
    @totals << (@workloads.inject(0) { |sum,w| sum += w.three_next_months_percents} / size).round
    @cap_totals << (@workloads.inject(0) { |sum,w| sum += cap(w.three_next_months_percents)} / size).round
    @avail_totals << ''
    # availability 2 mths
    @totals << ''
    @cap_totals << ''
    @avail_totals << (@workloads.inject(0) { |sum,w| sum += w.sum_availability })
    # per weeks
    @workloads.first.weeks.each_with_index do |tmp,i|
      @totals << (@workloads.inject(0) { |sum,w| sum += w.percents[i][:precise]} / size).round
      @chart_totals << (@workloads.inject(0) { |sum,w| w.person.is_virtual==1 ? 0.0 : sum += w.percents[i][:precise]} / chart_size).round
      @cap_totals << (@workloads.inject(0) { |sum,w| sum += cap(w.percents[i][:precise])} / size).round
      @chart_cap_totals << (@workloads.inject(0) { |sum,w| w.person.is_virtual==1 ? 0.0 : sum += cap(w.percents[i][:precise])} / chart_size).round
      @avail_totals << (@workloads.inject(0) { |sum,w| sum += w.availability[i][:avail]})
    end

    # workload chart
    chart = GoogleChart::LineChart.new('1000x300', "Workload (without virtual people)", false)
    realmax     = [@chart_totals.max, @chart_cap_totals.max].max
    high_limit  = 150.0
    max         = realmax > high_limit ? high_limit : realmax
    high_limit  = high_limit > max ? max : high_limit
    cap_serie   = @chart_cap_totals.map { |p| p <= max ? p : max}
    noncap_serie = @chart_totals.map { |p| p <= max ? p : max}
    chart.data "capped", cap_serie, 'ff0000'
    chart.data "non capped", noncap_serie, '0000ff'
    #chart.add_labels @chart_cap_totals
    chart.axis :y, :range => [0,max], :font_size => 10, :alignment => :center
    chart.axis :x, :labels => @workloads.first.months, :font_size => 10, :alignment => :center
    chart.shape_marker :circle, :color=>'ff3333', :data_set_index=>0, :data_point_index=>-1, :pixel_size=>8
    chart.shape_marker :circle, :color=>'3333ff', :data_set_index=>1, :data_point_index=>-1, :pixel_size=>8
    @chart_cap_totals.each_with_index do |p,index|
      if p > high_limit
        chart.shape_marker :circle, :color=>'333333', :data_set_index=>0, :data_point_index=>index, :pixel_size=>8
      end
    end
    @chart_totals.each_with_index do |p,index|
      if p > high_limit
        chart.shape_marker :circle, :color=>'ff3333', :data_set_index=>1, :data_point_index=>index, :pixel_size=>8
      end
    end
    chart.range_marker :horizontal, :color=>'EEEEEE', :start_point=>95.0/max, :end_point=>105.0/max
    chart.show_legend = true
    #chart.enable_interactivity = true
    #chart.params[:chm] = "h,FF0000,0,-1,1"
    @chart_url = chart.to_url #({:chm=>"r,DDDDDD,0,#{100.0/max-0.01},#{100.0/max}"}) #({:enableInteractivity=>true})

    if APP_CONFIG['use_virtual_people']
      # staffing chart
      serie = []
      @workloads.first.weeks.each_with_index do |tmp,i|
        serie << @workloads.inject(0) { |sum,w| sum += w.staffing[i]}
      end
      chart = GoogleChart::LineChart.new('1000x300', "Staffing", false)
      max   = serie.max
      chart.data "nb person", serie, 'ff0000'
      chart.axis :y, :range => [0,max], :font_size => 10, :alignment => :center
      chart.axis :x, :labels => @workloads.first.months, :font_size => 10, :alignment => :center
      chart.shape_marker :circle, :color=>'ff3333', :data_set_index=>0, :data_point_index=>-1, :pixel_size=>8
      chart.show_legend = true
      @staffing_chart_url = chart.to_url #({:chm=>"r,DDDDDD,0,#{100.0/max-0.01},#{100.0/max}"}) #({:enableInteractivity=>true})
    end
    render :layout => false
  end

  def cap(nb)
    nb > 100 ? 100 : nb
  end

  def refresh_holidays
    @people = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0", :order=>"name")
    @workloads = []
    for p in @people
      @workloads << Workload.new(p.id,session['workload_person_project_ids'],session['workload_persons_iterations'], {:only_holidays=>true})
    end
    @workloads = @workloads.sort_by {|w| [w.person.name]}
    render :layout => false
  end

  # Find all lines without tasks
  def refresh_missing_tasks
    @lines = WlLine.find(:all, :conditions=>"wl_lines.id not in (select wl_line_id from wl_line_tasks) and wl_lines.wl_type=200", :order=>"project_id, person_id")
    render :layout => false
  end

  # find all SDP tasks not associated to workload lines
  def refresh_missing_wl_lines
    task_ids  = WlLineTask.find(:all, :select=>"sdp_task_id").map{ |t| t.sdp_task_id}.uniq
    @tasks    = SDPTask.find(:all, :conditions=>"remaining > 0 and sdp_id not in (#{task_ids.join(',')})", :order=>"project_code, title")
    render :layout => false
  end

  def refresh_requests_to_validate
    @requests = Request.find(:all, :conditions=>"status='to be validated'", :order=>"summary")
    @week1    = wlweek(Date.today)
    @week2    = wlweek(Date.today+7.days)
    @requests = @requests.select {|r| wl = r.wl_line; wl and (wl.get_load_by_week(@week1) > 0 or wl.get_load_by_week(@week2) > 0)}
    render :layout => false
  end

  def add_by_request
    request_id = params[:request_id]
    if !request_id or request_id.empty?
      @error = "Please provide a request number."
      return
    end
    request_id.strip!
    person_id = session['workload_person_id'].to_i
    # person_id                     = params[:wl_person].to_i
    session['workload_person_id'] = person_id.to_s
    filled = filled_number(request_id,7)
    request = Request.find_by_request_id(filled)
    if not request
      @error = "Can not find request with number #{request_id}"
      return
    end
    project = request.project
    name = request.workload_name
    found = WlLine.find_by_person_id_and_request_id(person_id, request_id)
    if not found
      @line = WlLine.create(:name=>name, :request_id=>request_id, :person_id=>person_id, :wl_type=>WL_LINE_REQUEST)
      get_workload_data(person_id,session['workload_person_project_ids'],session['workload_persons_iterations'])
    else
      @error = "This line already exists: #{request_id}"
    end
  end

  def add_by_name
    name = params[:name].strip
    if name.empty?
      @error = "Please provide a name."
      return
    end
    person_id = session['workload_person_id'].to_i
    # person_id                     = params[:wl_person].to_i
    session['workload_person_id'] = person_id.to_s
    found = WlLine.find_by_person_id_and_name(person_id, name)
    if not found
      @line = WlLine.create(:name=>name, :request_id=>nil, :person_id=>person_id, :wl_type=>WL_LINE_OTHER)
      get_workload_data(person_id,session['workload_person_project_ids'],session['workload_persons_iterations'])
    else
      @error = "This line already exists: #{name}"
    end
  end

  def add_by_sdp_task
    sdp_task_id                   = params[:sdp_task_id].to_i
    person_id                     = params[:wl_person].to_i
    session['workload_person_id'] = person_id.to_s
    sdp_task    = SDPTask.find_by_sdp_id(sdp_task_id)
    if not sdp_task
      @error = "Can not find SDP Task with id #{sdp_task_id}"
      return
    end
    found = WlLineTask.find(:first, :conditions=>["sdp_task_id=?",sdp_task_id])
    if not found
      @line     = WlLine.create(:name=>sdp_task.title, :person_id=>person_id, :wl_type=>WL_LINE_OTHER)
      WlLineTask.create(:wl_line_id=>@line.id, :sdp_task_id=>sdp_task_id) 
      if(APP_CONFIG['auto_link_task_to_project']) and sdp_task.project
        @line.project_id = sdp_task.project.id 
        @line.save
      end
    else
      @error = "Task '#{found.sdp_task.title}' is already linked to workload line '#{found.wl_line.name}'"
    end
    get_workload_data(person_id,session['workload_person_project_ids'],session['workload_persons_iterations'])
  end

  def add_by_project
    project_id = params[:project_id].to_i
    person_id = session['workload_person_id'].to_i
    # person_id                     = params[:wl_person].to_i
    session['workload_person_id'] = person_id.to_s
    project = Project.find(project_id)
    if not project
      @error = "Can not find project with id #{project_id}"
      return
    end
    found = WlLine.find_by_project_id_and_person_id(project_id, person_id)
    # allow to add several lines by projet
    #if not found
      @line = WlLine.create(:name=>project.name, :project_id=>project_id, :person_id=>person_id, :wl_type=>WL_LINE_OTHER)
    #else
    #  @error = "This line already exists: #{found.name}"
    #end
    get_workload_data(person_id,session['workload_person_project_ids'],session['workload_persons_iterations'])
  end

  def display_edit_line
    line_id   = params[:l].to_i
    @wl_line  = WlLine.find(line_id)
    @workload = Workload.new(session['workload_person_id'],session['workload_person_project_ids'],session['workload_persons_iterations'])
    if APP_CONFIG['workloads_add_by_project']
      @projects = Project.all.map {|p| ["#{p.name} (#{p.wl_lines.size} lines)", p.id]}
    end
    if @workload.person.trigram == ""
      @sdp_tasks = []
    else
      get_sdp_tasks(@workload)
    end
  end

  def edit_line
    @wl_line = WlLine.find(params[:id])
    @wl_line.update_attributes(params[:wl_line])
    @workload = Workload.new(@wl_line.person_id,session['workload_person_project_ids'],session['workload_persons_iterations'])
  end

  def destroy_line
    @wl_line_id     = params[:id]
    wl_line         = WlLine.find(@wl_line_id)
    person_id       = wl_line.person_id
    wl_line.destroy
    WlLineTask.find(:all, :conditions=>["wl_line_id=?",@wl_line_id]).each do |l|
      l.destroy
    end
    @workload = Workload.new(person_id,session['workload_person_project_ids'],session['workload_persons_iterations'])
    get_sdp_tasks(@workload)
  end

  def link_to_request
    request_id  = params[:request_id].strip
    line_id     = params[:id]
    if request_id.empty?
      @error = "Please provide a request number."
      return
    end
    person_id = session['workload_person_id'].to_i
    # person_id                     = params[:wl_person].to_i
    session['workload_person_id'] = person_id.to_s
    filled = filled_number(request_id,7)
    request = Request.find_by_request_id(filled)
    if not request
      @error = "Can not find request with number #{request_id}"
      return
    end
    project = request.project
    name = request.workload_name
    found = WlLine.find_by_person_id_and_request_id(person_id, request_id)
    if not found
      @wl_line = WlLine.find(line_id)
      @wl_line.name = name
      @wl_line.request_id = request_id
      @wl_line.wl_type = WL_LINE_REQUEST
      @wl_line.save
      @workload = Workload.new(person_id,session['workload_person_project_ids'],session['workload_persons_iterations'])
    else
      @error = "This line already exists: #{request_id}"
    end
  end

  def unlink_request
    line_id             = params[:id]
    @wl_line            = WlLine.find(line_id)
    @wl_line.request_id = nil
    @wl_line.wl_type    = WL_LINE_OTHER
    @wl_line.save
    @workload           = Workload.new(@wl_line.person_id,session['workload_person_project_ids'],session['workload_persons_iterations'])
  end
  def update_settings_name
    update_status = params[:on]

    if update_status=='true'
      current_user.settings.wl_line_change_name = 1
    else
      current_user.settings.wl_line_change_name = 0
    end
    current_user.save
    render(:nothing=>true)
  end
  def link_to_sdp
    sdp_task_id       = params[:sdp_task_id].to_i
    line_id           = params[:id]
    task              = SDPTask.find_by_sdp_id(sdp_task_id)
    @wl_line          = WlLine.find(line_id)
    @wl_line.add_sdp_task_by_id(sdp_task_id) if not @wl_line.sdp_tasks.include?(task)
    update_line_name(@wl_line) if ( current_user.settings.wl_line_change_name == 1 )
    @wl_line.wl_type  = WL_LINE_OTHER
    @wl_line.save
    @workload         = Workload.new(@wl_line.person_id,session['workload_person_project_ids'],session['workload_persons_iterations'])
    get_sdp_tasks(@workload)
  end

  def unlink_sdp_task
    sdp_task_id = params[:sdp_task_id].to_i
    line_id     = params[:id]
    @wl_line    = WlLine.find(line_id)
    person      = Person.find(session['workload_person_id'].to_i)
    @wl_line.delete_sdp(sdp_task_id)
    update_line_name(@wl_line) if ( current_user.settings.wl_line_change_name == 1 )
    @wl_line.save
    @workload         = Workload.new(@wl_line.person_id,session['workload_person_project_ids'],session['workload_persons_iterations'])
    get_sdp_tasks(@workload)
  end

  def link_to_project
    project_id          = params[:project_id].to_i
    line_id             = params[:id]
    @wl_line            = WlLine.find(line_id)
    @wl_line.project_id = project_id
    @wl_line.wl_type    = WL_LINE_OTHER
    @wl_line.save
    @workload           = Workload.new(@wl_line.person_id,session['workload_person_project_ids'],session['workload_persons_iterations'])
  end

  def unlink_project
    line_id             = params[:id]
    @wl_line            = WlLine.find(line_id)
    @wl_line.project_id = nil
    @wl_line.wl_type    = WL_LINE_OTHER
    @wl_line.save
    @workload           = Workload.new(@wl_line.person_id,session['workload_person_project_ids'],session['workload_persons_iterations'])
  end

  def edit_load
    view_by = (params['view_by']=='1' ? :project : :person)
    @line_id  = params[:l].to_i
    @wlweek   = params[:w].to_i
    value     = round_to_hour(params[:v].to_f)
    line      = WlLine.find(@line_id)
    id        = view_by==:person ? line.person_id : line.project_id
    if value == 0.0
      if (line.wl_type == WL_LINE_HOLIDAYS)
        backup = WlBackup.find(:all, :conditions=>["person_id = ? and week = ?", line.person.id.to_s, @wlweek])
        # Send email
        backup.each do |b|
         Mailer::deliver_backup_delete(b)
        end
        backup.each(&:destroy)
      end
      WlLoad.delete_all(["wl_line_id=? and week=?",@line_id, @wlweek])
      @value = ""
    else
      wl_load = WlLoad.find_by_wl_line_id_and_week(@line_id, @wlweek)
      wl_load = WlLoad.create(:wl_line_id=>@line_id, :week=>@wlweek) if not wl_load
      wl_load.wlload = value
      wl_load.save
      @value = value
    end
    @lsum, @plsum, @csum, @cpercent, @case_percent, @total, @planned_total, @avail  = get_sums(line, @wlweek, id, view_by)
  end

  # type is :person or :projet and indicates what is the id (person or projet)
  def get_sums(line, week, id, type=:person)
    @type       = type
    today_week  = wlweek(Date.today)
    plsum       = line.wl_loads.map{|l| (l.week < today_week ? 0 : l.wlload)}.inject(:+)
    lsum        = line.wl_loads.map{|l| l.wlload}.inject(:+)
    if(type==:project)
      wl_lines = WlLine.find(:all, :conditions=>["project_id in (#{session['workload_project_ids'].join(',')})"])
      person_wl_lines = WlLine.find(:all, :conditions=>["person_id=?", line.person.id])
      case_sum       = person_wl_lines.map{|l| l.get_load_by_week(week)}.inject(:+)
      case_sum       = 0 if !case_sum
      nb_days_per_weeks = 5 * wl_lines.map{|l| l.person_id}.uniq.size
    else
      wl_lines = WlLine.find(:all, :conditions=>["person_id=?", id])
      nb_days_per_weeks = 5
    end
    csum       = wl_lines.map{|l| l.get_load_by_week(week)}.inject(:+)
    csum       = 0 if !csum
    case_sum   = csum if type==:person
    open       = nb_days_per_weeks
    wl_lines.map{|l| l.person}.uniq.each do |p|
      company  = Company.find_by_id(p.company_id)
      open     = open - WlHoliday.get_from_week_and_company(week,company)
    end
    company    = Company.find_by_id(line.person.company_id)
    person_open = 5 - WlHoliday.get_from_week_and_company(week,company)
    # cpercent is the percent of occupation for a week. It depends of the view (person or project)
    cpercent   = open > 0 ? (csum / open*100).round : 0
    # case_percent is the percent of occupation for a week for a person. It does not depend of the view (person or project)
    case_percent = open > 0 ? (case_sum / person_open*100).round : 0
    avail      = [0,(open-csum)].max
    avail      = (avail==0 ? '' : avail)

    planned_total = 0
    total         = 0
    for l in wl_lines
      next if l.wl_type > 200
      l.wl_loads.each { |load|
        total += load.wlload
        planned_total += (load.week < today_week ? 0 : load.wlload)
        }
    end

    [lsum, plsum, csum, cpercent, case_percent, total, planned_total, avail]
  end

  def transfert
    @people = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0", :order=>"name").map {|p| ["#{p.name} (#{p.wl_lines.size} lines)", p.id]}
    # WL Lines without project
    @lines = WlLine.find(:all, :conditions=>["person_id=? and project_id IS NULL",  session['workload_person_id']],
      :include=>["request","wl_line_task","person"], :order=>"wl_type, name")
    # WL lines by project
    temp_lines_qr_qwr = WlLine.find(:all, :conditions=>["person_id=? and project_id IS NOT NULL",  session['workload_person_id']],
      :include=>["request","wl_line_task","person"], :order=>"wl_type, name")
    @lines_qr_qwr = Hash.new
    temp_lines_qr_qwr.each do |wl|
        @lines_qr_qwr[wl.project_id] = [wl]
    end
    @owner_id = session['workload_person_id']
  end

  def do_transfert
    # Params
    lines        = params['lines'] # array of ids (as strings)
    lines_qr_qwr = params['lines_qr_qwr'] # array of ids of wl lines qr qwr (as strings)
    p_id         = params['person_id']
    owner_id     = params['owner_id']

    # Lines to transfert
    if lines
      lines.each { |l_id|
        l = WlLine.find(l_id.to_i)
        l.person_id = p_id.to_i
        l.save
      }
    end

    # Lines of qr_qwr to transfert
    if lines_qr_qwr
      lines_qr_qwr.each { |l_id|
        # Find all lines (two line by project qr_qwr)
        l = WlLine.find(l_id.to_i)
        WlLine.find(:all,:conditions=>["person_id = ? and project_id = ?",owner_id.to_s, l.project_id.to_s]).each { |line_by_project|
          line_by_project.person_id         = p_id.to_i
          line_by_project.project.qr_qwr_id = p_id.to_i
          line_by_project.save
          line_by_project.project.save
        }
      }
    end

    redirect_to(:action=>"transfert")
  end

  def duplicate
    @months   = []
    @weeks    = []
    @wl_weeks = []
    @months   = params[:months]
    @weeks    = params[:weeks]
    @wl_weeks = params[:wl_weeks]
    @people   = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0", :order=>"name").map {|p| ["#{p.name} (#{p.wl_lines.size} lines)", p.id]}

    # WL lines without project_id
    @lines    = WlLine.find(:all, :conditions=>["person_id=? and project_id IS NULL",  session['workload_person_id']],
      :include=>["request","wl_line_task","person"], :order=>"wl_type, name")

    # WL lines by project
    @lines_qr_qwr = WlLine.find(:all, :conditions=>["person_id=? and project_id IS NOT NULL",  session['workload_person_id']],
      :include=>["request","wl_line_task","person"], :order=>"project_id,wl_type,name")
  end

  def do_duplication
    lines_loads         = params['lines_loads'] # array of lineId_loadId
    p_id  = params['person_id']

    lines_loads.each { |l_l|
      # Wl_line and Wl_load selected
      l_l_splited = l_l.split("_")
      line_id     = l_l_splited[0]
      load_id     = l_l_splited[1]
      line        = WlLine.find(line_id.to_i)
      load        = WlLoad.find(load_id.to_i)

      # Check if the line to duplicate isn't already duplicated from another line
      # If Line to duplicate is already duplicate, so we take the first line as parent_id
      parent_id = line.id
      if line.parent_line
        parent    = WlLine.find(line.parent_line)
        parent_id = parent.id
      end

      # Check if the person selected has not already a duplicate
      duplicate = 0 # Id of the Wl_line duplicated and managed by the person selected (0 if null)
      if line.duplicates != nil
        line.duplicates.each { |l|
          if l.person_id.to_s == p_id
            duplicate = l.id
          end
        }
      end

      # If the person selected has not already a duplicate, we create it
      if duplicate == 0
        new_line             = line.clone
        new_line.parent_line = parent_id
        new_line.person_id   = p_id
        new_line.save
        duplicate            = new_line.id
      end

      # Change wl_line of load selected
      load.wl_line_id = duplicate
      load.save

      # Project
      request = Request.first(:conditions=>["request_id = ?",line.request_id]) if line.request_id
      if request != nil
        project_id      = request.project_id
        project_person  = ProjectPerson.first(:conditions => ["project_id = ? and person_id = ?", project_id, p_id]) if project_id
        if project_person == nil
          project_person            = ProjectPerson.new
          project_person.project_id = project_id
          project_person.person_id  = p_id
          project_person.save
        end
      end
    }
    redirect_to(:action=>"index")
  end

  def hide_lines_with_no_workload
    on = (params[:on].to_s != 'false')
    session['workload_hide_lines_with_no_workload'] = on
    get_workload_data(session['workload_person_id'],session['workload_person_project_ids'],session['workload_persons_iterations'])
  end

  def hide_wmenu
    session['wmenu_hidden'] = params[:on]
    render(:nothing=>true)
  end

  def backup
    @people   = Person.find(:all, :conditions=>["has_left=0 and is_supervisor=0 and id != ?", session['workload_person_id']], :order=>"name").map {|p| ["#{p.name} (#{p.wl_lines.size} lines)", p.id]}
    @weeks = [['01', '01'],['02', '02'],['03', '03'],['04', '04'],['05', '05'],['06', '06'],['07', '07'],['08', '08'],['09', '09']] 
    (10..52).each{|i| @weeks << ["#{i}","#{i}"] }
    @years = [Time.new.year,Time.new.year+1]
    @backups      = WlBackup.find(:all, :conditions=>["person_id=?", session['workload_person_id']]);
    @self_backups = WlBackup.find(:all, :conditions=>["backup_person_id=?", session['workload_person_id']]);
  end
  
  def create_backup    
    b_id  = params['backup_person_id']
    p_id  = params['person_id']
    week  = params['week']

    backups = WlBackup.first(:conditions=>["backup_person_id = ? and person_id = ? and week = ?", b_id, p_id, week]);
    if (backups == nil)
      backup = WlBackup.new
      backup.backup_person_id = b_id
      backup.person_id = p_id
      backup.week = week
      backup.save
      render :text=>backup.week.to_s+"_"+backup.backup.name
    else
      render(:nothing=>true)
    end
  end

  def delete_backup
    backup_id = params['backup_id']
    backup = WlBackup.first(:conditions=>["id = ?", backup_id]);
    backup.destroy
    render(:nothing=>true)
  end

  def update_backup_comment
    backup_id      = params['backup_id']
    backup_comment = params['backup_comment']
    backup = WlBackup.first(:conditions=>["id = ?", backup_id]);
    if backup != nil
      backup.comment = backup_comment
      backup.save
    end
    render :text=>backup.comment, :layout => false 
  end

private

  def get_workload_data(person_id, projects_ids, person_iterations)
    @workload = Workload.new(person_id,projects_ids,person_iterations, {:hide_lines_with_no_workload => session['workload_hide_lines_with_no_workload'].to_s=='true'})
    @person   = @workload.person
    get_last_sdp_update
    get_suggested_requests(@workload)
    get_chart
    get_sdp_gain(@workload.person)
    get_sdp_tasks(@workload)
    get_backup_warnings(@workload.person)
    get_unlinked_sdp_tasks(@workload)
    get_holiday_warning(@workload.person)
  end

  def update_line_name(line)
    line.name = line.sdp_tasks.map{|p| p.title}.sort.join(', ')
    line.name = "No line name" if line.name == ""
  end

end
