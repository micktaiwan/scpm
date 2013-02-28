require 'rubygems'
require 'google_chart'
# http://badpopcorn.com/blog/2008/09/08/rails-google-charts-gchartrb/

class WorkloadsController < ApplicationController

  layout 'pdc'

  def index
    session['workload_person_id'] = current_user.id if not session['workload_person_id']
    @people = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0", :order=>"name").map {|p| ["#{p.name} (#{p.wl_lines.size} lines)", p.id]}
    change_workload(session['workload_person_id'])
  end

  def change_workload(person_id=nil)
    person_id = params[:person_id] if !person_id
    session['workload_person_id'] = person_id
    @workload = Workload.new(person_id, {:hide_lines_with_no_workload => session['workload_hide_lines_with_no_workload'].to_s=='true'})
    @person   = @workload.person
    get_last_sdp_update
    get_suggested_requests(@workload)
    get_sdp_tasks(@workload)
    get_chart
    get_sdp_gain(@workload.person)
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

  def get_sdp_tasks(wl)
    if wl.person.trigram == ""
      @sdp_tasks = []
      return
    end
    task_ids   = wl.wl_lines.select {|l| l.sdp_task_id != nil}.map { |l| l.sdp_task_id}
    cond = ""
    cond = " and sdp_id not in (#{task_ids.join(',')})" if task_ids.size > 0
    @sdp_tasks = SDPTask.find(:all, :conditions=>["collab=? and request_id is null and remaining > 0 #{cond}", wl.person.trigram], :order=>"title").map{|t| ["#{ActionController::Base.helpers.sanitize(t.title)} (#{t.remaining})", t.sdp_id]}
  end

  def get_sdp_gain(person)
    @balance = person.sdp_balance
    @sdp_logs = SdpLog.find(:all, :conditions=>["person_id=?", person.id], :order=>"`date` desc", :limit=>3).reverse
  end

  # just for loading tabs
  def consolidation
  end

  def refresh_conso
    @start_time = Time.now
    # find "to be validated" requests not in the workload
    already_in_the_workload = WlLine.all.select{|l| l.request and (l.request.status=='to be validated' or (l.request.status=='assigned' and l.request.resolution!='ended' and l.request.resolution!='aborted'))}.map{|l| l.request}
    @not_in_workload = (Request.find(:all,:conditions=>"status='to be validated' or (status='assigned' and resolution!='ended' and resolution!='aborted')") - already_in_the_workload).sort_by{|r| (r.project ? r.project.full_name : "")}
    # find the corresponding production days (minus 20% of gain)
    @not_in_workload_days = @not_in_workload.inject(0) { |sum, r| sum += r.workload2} * 0.80

    @people = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0 and is_transverse=0", :order=>"name")
    @transverse_people = Person.find(:all, :conditions=>"has_left=0 and is_transverse=1", :order=>"name").map{|p| p.name.split(" ")[0]}.join(", ")
    @workloads = []
    @total_days = 0
    @total_planned_days = 0
    @to_be_validated_in_wl_remaining_total = 0
    for p in @people
      w = Workload.new(p.id)
      @workloads << w
      @total_days += w.line_sums.inject(0) { |sum, (k,v)| sum += v[:remaining] == '' ? 0 : v[:remaining]}
      @total_planned_days += w.planned_total
      @to_be_validated_in_wl_remaining_total += w.to_be_validated_in_wl_remaining_total
      #break
    end
    @workloads = @workloads.sort_by {|w| [w.next_month_percents, w.three_next_months_percents, w.person.name]}
    @totals       = []
    @cap_totals   = []
    @avail_totals = []
    size          = @workloads.size

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
      @cap_totals << (@workloads.inject(0) { |sum,w| sum += cap(w.percents[i][:precise])} / size).round
      @avail_totals << (@workloads.inject(0) { |sum,w| sum += w.availability[i][:avail]})
    end

    chart = GoogleChart::LineChart.new('1000x300', "Workload", false)
    realmax     = [@totals[4..-1].max, @cap_totals[4..-1].max].max
    high_limit  = 150.0
    max         = realmax > high_limit ? high_limit : realmax
    high_limit  = high_limit > max ? max : high_limit
    cap_serie   = @cap_totals[4..-1].map { |p| p <= max ? p : max}
    noncap_serie = @totals[4..-1].map { |p| p <= max ? p : max}
    chart.data "capped", cap_serie, 'ff0000'
    chart.data "non capped", noncap_serie, '0000ff'
    #chart.add_labels @cap_totals[3..-1]
    chart.axis :y, :range => [0,max], :font_size => 10, :alignment => :center
    chart.axis :x, :labels => @workloads.first.months, :font_size => 10, :alignment => :center
    chart.shape_marker :circle, :color=>'ff3333', :data_set_index=>0, :data_point_index=>-1, :pixel_size=>8
    chart.shape_marker :circle, :color=>'3333ff', :data_set_index=>1, :data_point_index=>-1, :pixel_size=>8
    @cap_totals[4..-1].each_with_index do |p,index|
      if p > high_limit
        chart.shape_marker :circle, :color=>'333333', :data_set_index=>0, :data_point_index=>index, :pixel_size=>8
      end
    end
    @totals[4..-1].each_with_index do |p,index|
      if p > high_limit
        chart.shape_marker :circle, :color=>'ff3333', :data_set_index=>1, :data_point_index=>index, :pixel_size=>8
      end
    end
    chart.range_marker :horizontal, :color=>'EEEEEE', :start_point=>95.0/max, :end_point=>105.0/max
    chart.show_legend = true
    #chart.enable_interactivity = true
    #chart.params[:chm] = "h,FF0000,0,-1,1"
    @chart_url = chart.to_url #({:chm=>"r,DDDDDD,0,#{100.0/max-0.01},#{100.0/max}"}) #({:enableInteractivity=>true})
    render :layout => false
  end

  def cap(nb)
    nb > 100 ? 100 : nb
  end

  def refresh_holidays
    @people = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0", :order=>"name")
    @workloads = []
    for p in @people
      @workloads << Workload.new(p.id, {:only_holidays=>true})
    end
    @workloads = @workloads.sort_by {|w| [w.person.name]}
    render :layout => false
  end

  def refresh_missing_tasks
    @lines = WlLine.find(:all, :conditions=>"wl_lines.sdp_task_id is null and wl_lines.wl_type=200", :order=>"person_id")
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
      @workload = Workload.new(person_id)
      get_last_sdp_update
      get_suggested_requests(@workload)
      #get_sdp_gain(@workload.person)
      get_chart
      get_sdp_gain(@workload.person)
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
    found = WlLine.find_by_person_id_and_name(person_id, name)
    if not found
      @line = WlLine.create(:name=>name, :request_id=>nil, :person_id=>person_id, :wl_type=>WL_LINE_OTHER)
      @workload = Workload.new(person_id)
      get_last_sdp_update
      get_suggested_requests(@workload)
      #get_sdp_gain(@workload.person)
      get_chart
      get_sdp_gain(@workload.person)
    else
      @error = "This line already exists: #{name}"
    end
  end

  def add_by_sdp_task
    sdp_task_id = params[:sdp_task_id].to_i
    person_id = session['workload_person_id'].to_i
    sdp_task = SDPTask.find_by_sdp_id(sdp_task_id)
    if not sdp_task
      @error = "Can not find SDP Task with id #{sdp_task_id}"
      return
    end
    found = WlLine.find_by_sdp_task_id(sdp_task_id)
    if not found
      @line = WlLine.create(:name=>sdp_task.title, :sdp_task_id=>sdp_task_id, :person_id=>person_id, :wl_type=>WL_LINE_OTHER)
    else
      @error = "This line already exists: #{found.name}"
    end
    @workload = Workload.new(person_id)
    get_last_sdp_update
    get_suggested_requests(@workload)
    get_sdp_gain(@workload.person)
    get_chart
  end

  def edit_load
    @line_id  = params[:l].to_i
    @wlweek   = params[:w].to_i
    value     = round_to_hour(params[:v].to_f)
    line      = WlLine.find(@line_id)
    person_id = line.person_id

    if value == 0.0
      WlLoad.delete_all(["wl_line_id=? and week=?",@line_id, @wlweek])
      @value = ""
    else
      wl_load = WlLoad.find_by_wl_line_id_and_week(@line_id, @wlweek)
      wl_load = WlLoad.create(:wl_line_id=>@line_id, :week=>@wlweek) if not wl_load
      wl_load.wlload = value
      wl_load.save
      @value = value
    end
    @lsum, @csum, @cpercent, @planned_total, @avail  = get_sums(line, @wlweek, person_id)
  end

  def display_edit_line
    line_id   = params[:l].to_i
    @wl_line  = WlLine.find(line_id)
    @workload = Workload.new(session['workload_person_id'])
    if @workload.person.trigram == ""
      @sdp_tasks = []
    else
      get_sdp_tasks(@workload)
    end
  end

  def edit_line
    @wl_line = WlLine.find(params[:id])
    @wl_line.update_attributes(params[:wl_line])
    @workload = Workload.new(@wl_line.person_id)
  end

  def destroy_line
    WlLine.find(params[:id]).destroy
    render(:nothing=>true)
  end

  def link_to_request
    request_id  = params[:request_id].strip
    line_id     = params[:id]
    if request_id.empty?
      @error = "Please provide a request number."
      return
    end
    person_id = session['workload_person_id'].to_i
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
      @workload = Workload.new(person_id)
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
    @workload = Workload.new(@wl_line.person_id)
  end

  def link_to_sdp
    sdp_task_id  = params[:sdp_task_id].to_i
    line_id     = params[:id]
    person_id = session['workload_person_id'].to_i
    task = SDPTask.find_by_sdp_id(sdp_task_id)
    @wl_line = WlLine.find(line_id)
    @wl_line.name = task.title
    @wl_line.sdp_task_id = sdp_task_id
    @wl_line.wl_type = WL_LINE_OTHER
    @wl_line.save
    @workload = Workload.new(@wl_line.person_id)
  end

  def unlink_sdp
    line_id               = params[:id]
    @wl_line              = WlLine.find(line_id)
    @wl_line.sdp_task_id  = nil
    @wl_line.wl_type      = WL_LINE_OTHER
    @wl_line.save
    @workload = Workload.new(@wl_line.person_id)
  end

  def get_sums(line, week, person_id)
    today_week = wlweek(Date.today)
    lsum = line.wl_loads.map{|l| (l.week < today_week ? 0 : l.wlload)}.inject(:+)
    wl_lines    = WlLine.find(:all, :conditions=>["person_id=?", person_id])
    csum = wl_lines.map{|l| l.get_load_by_week(week)}.inject(:+)
    cpercent = (csum / (5-WlHoliday.get_from_week(week))*100).round
    open    = 5 - WlHoliday.get_from_week(week)
    avail   = [0,(open-csum)].max
    avail   = (avail==0 ? '' : avail)

    planned_total = 0
    for l in wl_lines
      s = (l.wl_loads.map{|load| (load.week < today_week ? 0 : load.wlload)}.inject(:+))
      planned_total  +=  s if l.wl_type <= 200 and s
    end

    [lsum, csum, cpercent, planned_total, avail]
  end

  def transfert
    @people = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0", :order=>"name").map {|p| ["#{p.name} (#{p.wl_lines.size} lines)", p.id]}
    # WL Lines without project
    @lines = WlLine.find(:all, :conditions=>["person_id=? and project_id IS NULL",  session['workload_person_id']],
      :include=>["request","sdp_task","person"], :order=>"wl_type, name")
    # WL lines by project
    temp_lines_qr_qwr = WlLine.find(:all, :conditions=>["person_id=? and project_id IS NOT NULL",  session['workload_person_id']],
      :include=>["request","sdp_task","person"], :order=>"wl_type, name")
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
    @months = []
    @weeks = []
    @wl_weeks = []
    @months = params[:months]
    @weeks = params[:weeks]
    @wl_weeks = params[:wl_weeks]
    @people = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0", :order=>"name").map {|p| ["#{p.name} (#{p.wl_lines.size} lines)", p.id]}
    @lines = WlLine.find(:all, :conditions=>["person_id=?",  session['workload_person_id']],
      :include=>["request","sdp_task","person"], :order=>"wl_type, name")
  end

  def do_duplication
    lines_loads = params['lines_loads'] # array of lineId_loadId
    p_id  = params['person_id']

    lines_loads.each { |l_l|
      # Wl_line and Wl_load selected
      l_l_splited = l_l.split("_")
      line_id = l_l_splited[0]
      load_id = l_l_splited[1]
      line = WlLine.find(line_id.to_i)
      load = WlLoad.find(load_id.to_i)

      # Check if the line to duplicate isn't already duplicated from another line
      # If Line to duplicate is already duplicate, so we take the first line as parent_id
      parent_id = line.id
      if line.parent_line
        parent = WlLine.find(line.parent_line)
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
        new_line = line.clone
        new_line.parent_line = parent_id
        new_line.person_id = p_id
        new_line.save
        duplicate = new_line.id
      end

      # Change wl_line of load selected
      load.wl_line_id = duplicate
      load.save

      # Project
      request = Request.find(line.request_id) if line.request_id
      if request != nil
        project_id = request.project_id
        project_person = ProjectPerson.first(:conditions => ["project_id = ? and person_id = ?", project_id, p_id]) if project_id
        if project_person == nil
          project_person = ProjectPerson.new
          project_person.project_id = project_id
          project_person.person_id = p_id
          project_person.save
        end
      end
    }
    redirect_to(:action=>"index")
  end

  def hide_lines_with_no_workload
    on = params[:on].to_s == 'true'
    session['workload_hide_lines_with_no_workload'] = on
    @workload = Workload.new(session['workload_person_id'], {:hide_lines_with_no_workload => on})
    @person   = @workload.person
    get_last_sdp_update
    get_suggested_requests(@workload)
    get_sdp_tasks(@workload)
    get_chart
    get_sdp_gain(@workload.person)
  end

  def hide_wmenu
    session['wmenu_hidden'] = params[:on]
    render(:nothing=>true)
  end

end
