class Workload

  include ApplicationHelper

  attr_reader :name, :weeks, :wl_weeks, :person_id, :wl_lines, :line_sums,
              :opens, :ctotals, :percents, :months, :days, :person, :next_month_percents, :total_percents,
              :planned_total

  def initialize(person_id)
    @person     = Person.find(person_id)
    raise "could not find this person by id '#{person_id}'" if not @person
    @person_id  = person_id
    @name       = @person.name

    # calculate lines
    @wl_lines   = WlLine.find(:all, :conditions=>["person_id=?", person_id], :order=>"wl_type, name")
    @wl_lines  << WlLine.create(:name=>"Congés", :request_id=>nil, :person_id=>person_id, :wl_type=>WorkloadsController::WL_LINE_HOLIDAYS) if @wl_lines.size == 0
    from_day    = Date.today - (Date.today.cwday-1).days
    #farest_week = @wl_lines.map{|l| m = l.wl_loads.map{|l| l.week}.max; m ? m:0}.max
    farest_week = wlweek(from_day+6.months) # if farest_week == 0
    @wl_weeks   = []
    @weeks      = []
    @opens      = []
    @ctotals    = []
    @percents   = []
    @months     = []
    @days       = []
    month = Date::ABBR_MONTHNAMES[(from_day+4.days).month]
    month_displayed = false
    nb = 0
    iteration = from_day
    @next_month_percents = 0.0
    @total_percents = 0.0
    while true
      w = wlweek(iteration)
      break if w > farest_week or nb > 6*4

      # months
      if Date::ABBR_MONTHNAMES[(iteration+4.days).month] != month
        month = Date::ABBR_MONTHNAMES[(iteration+4.days).month]
        month_displayed = false
      end
      if not month_displayed
        @months   << month
        month_displayed = true
      else
        @months << ''
      end
      @days << filled_number(iteration.day,2) + "-" + filled_number((iteration+4.days).day,2)
      @wl_weeks << w
      @weeks    << iteration.cweek
      @opens    << 5 - WlHoliday.get_from_week(w)

      if @wl_lines.size > 0
        @ctotals << {:name=>'ctotal',    :id=>w, :value=>col_sum(w, @wl_lines)}
        percent = (@ctotals.last[:value] / @opens.last)*100
        @next_month_percents += percent if nb < 5
        @total_percents += percent
        @percents << {:name=>'cpercent', :id=>w, :value=>percent.round.to_s+"%"}
      end
      iteration = iteration + 7.days
      nb += 1
    end
    @next_month_percents = (@next_month_percents / 5).round
    @total_percents = (@total_percents / nb).round

    # sum the lines
    @line_sums = Hash.new
    today_week = wlweek(Date.today)
    @planned_total = 0
    for l in @wl_lines.select { |line| line.wl_type <= 200}
      @line_sums[l.id] = l.wl_loads.map{|load| (load.week < today_week ? 0 : load.wlload)}.inject(:+)
      @planned_total  += (@line_sums[l.id] ? @line_sums[l.id] : 0)
    end

    # calculate sums or not.... js is enough... or not, as we want to have the colors as soon as we load the page ? Can we do it by js at page load ? yes.
  end

  def col_sum(w, wl_lines)
    wl_lines.map{|l| l.get_load_by_week(w)}.inject(:+)
  end

end

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
  end

  def get_suggested_requests(wl)
    request_ids   = wl.wl_lines.select {|l| l.request_id != nil}.map { |l| filled_number(l.request_id,7)}
    cond = ""
    cond = " and request_id not in (#{request_ids.join(',')})" if request_ids.size > 0
    @suggested_requests = Request.find(:all, :conditions => "assigned_to='#{wl.person.rmt_user}' and status!='closed' and status!='performed' and status!='cancelled' and resolution!='ended'" + cond, :order=>"project_name, summary")
  end

  def consolidation
    @people = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0", :order=>"name")
    @workloads = []
    for p in @people
      @workloads << Workload.new(p.id)
    end
    @workloads = @workloads.sort_by {|w| [w.next_month_percents, w.total_percents, w.person.name]}
  end

  def change_workload
    person_id = params[:person_id]
    session['workload_person_id'] = person_id
    @workload = Workload.new(person_id)
    get_suggested_requests(@workload)
  end

  def add_by_request
    request_id = params[:request_id].strip
    if request_id.empty?
      @error = "Please provide a request number.\nTo close this window, click again on 'Add a line'."
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
    else
      @error = "This line already exists: #{request_id}"
    end
    @workload = Workload.new(person_id)
    get_suggested_requests(@workload)
  end

  def add_by_name
    name = params[:name].strip
    if name.empty?
      @error = "Please provide a name.\nTo close this window, click again on 'Add a line'."
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
    @wl_line      = WlLine.find(line_id)
  end

  def edit_line
    @wl_line = WlLine.find(params[:id])
    @wl_line.update_attributes(params[:wl_line])
    @workload = Workload.new(@wl_line.person_id)
  end

  def get_sums(line, week, person_id)
    lsum = line.wl_loads.map{|l| l.wlload}.inject(:+)
    wl_lines    = WlLine.find(:all, :conditions=>["person_id=?", person_id])
    csum = wl_lines.map{|l| l.get_load_by_week(week)}.inject(:+)
    cpercent = (csum / (5-WlHoliday.get_from_week(week))*100).round
    
    today_week = wlweek(Date.today)
    planned_total = 0
    for l in wl_lines.select { |line| line.wl_type <= 200}
      planned_total  += l.wl_loads.map{|load| (load.week < today_week ? 0 : load.wlload)}.inject(:+)
    end
    
    [lsum, csum, cpercent, planned_total]
  end

  def round_to_hour(f)
    (f/0.125).round*0.125
  end

end

