class WorkloadsController < ApplicationController

  layout 'pdc'

  WL_LINE_REQUEST   = 100
  WL_LINE_OTHER     = 200
  WL_LINE_HOLIDAYS  = 300 # not summed in the planned total
  WL_LINE_EXCEPT    = 400 # other tasks, not in the current project, not summed in the planned total

  def index
    session['workload_person_id'] = current_user.id if not session['workload_person_id']
    @workload = Workload.new(session['workload_person_id'])
    @people = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0", :order=>"name").map {|p| ["#{p.name} (#{p.wl_lines.size} lines)", p.id]}

    if @workload.person.rmt_user == ""
      @suggested_requests = []
    else
      get_suggested_requests(@workload)
    end
    if @workload.person.trigram == ""
      @sdp_tasks = []
    else
      get_sdp_tasks(@workload)
    end
  end

  def get_suggested_requests(wl)
    request_ids   = wl.wl_lines.select {|l| l.request_id != nil}.map { |l| filled_number(l.request_id,7)}
    cond = ""
    cond = " and request_id not in (#{request_ids.join(',')})" if request_ids.size > 0
    @suggested_requests = Request.find(:all, :conditions => "assigned_to='#{wl.person.rmt_user}' and status!='closed' and status!='performed' and status!='cancelled' and status!='removed' and resolution!='ended' #{cond}", :order=>"project_name, summary")
  end

  def get_sdp_tasks(wl)
    task_ids   = wl.wl_lines.select {|l| l.sdp_task_id != nil}.map { |l| l.sdp_task_id}
    cond = ""
    cond = " and id not in (#{task_ids.join(',')})" if task_ids.size > 0
    @sdp_tasks = SDPTask.find(:all, :conditions=>["collab=? and request_id is null and remaining > 0 #{cond}", wl.person.trigram], :order=>"title").map{|t| ["#{ActionController::Base.helpers.sanitize(t.title)} (#{t.remaining})", t.sdp_id]}
  end

  # just for loading tabs
  def consolidation
  end
  
  def refresh_conso
    @people = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0 and is_transverse=0", :order=>"name")
    @workloads = []
    for p in @people
      @workloads << Workload.new(p.id)
    end
    @workloads = @workloads.sort_by {|w| [w.next_month_percents, w.three_next_months_percents, w.person.name]}
    render :layout => false
  end

  def refresh_holidays
    @people = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0 and is_transverse=0", :order=>"name")
    @workloads = []
    for p in @people
      @workloads << Workload.new(p.id, {:only_holidays=>true})
    end
    @workloads = @workloads.sort_by {|w| [w.person.name]}
    render :layout => false
  end

  
  def change_workload
    person_id = params[:person_id]
    session['workload_person_id'] = person_id
    @workload = Workload.new(person_id)
    get_suggested_requests(@workload)
    get_sdp_tasks(@workload)
  end

  def add_by_request
    request_id = params[:request_id].strip
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
      @line = WlLine.create(:name=>name, :request_id=>request_id, :person_id=>person_id, :wl_type=>WL_LINE_REQUEST)
      @workload = Workload.new(person_id)
      get_suggested_requests(@workload)
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
    else
      @error = "This line already exists: #{name}"
    end
    @workload = Workload.new(person_id)
    get_suggested_requests(@workload)
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
    get_suggested_requests(@workload)
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
    @lsum, @csum, @cpercent, @planned_total  = get_sums(line, @wlweek, person_id)
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
    
    planned_total = 0
    for l in wl_lines
      s = (l.wl_loads.map{|load| (load.week < today_week ? 0 : load.wlload)}.inject(:+))
      planned_total  +=  s if l.wl_type <= 200 and s
    end

    [lsum, csum, cpercent, planned_total]
  end

  def round_to_hour(f)
    (f/0.125).round*0.125
  end

end

