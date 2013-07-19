class ProjectWorkload

  include ApplicationHelper

  attr_reader :name,  # project's name
    :weeks,           # arrays of week's names '43', '44', ...
    :wl_weeks,        # array of week ids '201143'
    :months,          # "Oct"
    :days,            # week days display per week: "17-21"
    :opens,           # total of worked days per week (5 - nb of holidays)
    :project,
    :project_id,
    :wl_lines,        # arrays of loads, all lines (filtered and not filtered)
    :displayed_lines, # only filtered lines
    :line_sums,       # sum of days per line of workload
    :ctotals,         # total days planned per week including not bundle days (holidays and other lines) {:id=>w, :value=>col_sum(w, @wl_lines)}
    :availability,    # total days of availability {:days=>xxx, :percent=>yyy}
    :sum_availability,# Sum of availabity days for the next 8 weeks
    :cprodtotals,     # total days planned per week on production only {:id=>w, :value=>col_prod_sum(w, @wl_lines)}
    :percents,        # total percent per week: {:name=>'cpercent', :id=>w, :value=>percent.round.to_s+"%", :precise=>percent}
    :next_month_percents,         # next 5 weeks (including current)
    :three_next_months_percents,  # next 3 months (was _after_ the 5 coming weeks but changed later including next 5 weeks)
    :total,                       # total number of days planned (including past weeks)
    :planned_total,               # total number of days planned (current week and after)
    :sdp_remaining_total,         # SDP remaining, including requests to be validated (non SDP task)
    :to_be_validated_in_wl_remaining_total, # total of requests to be validated planned in workloads
    :nb_total_lines,  # total before filters
    :nb_current_lines,# total after filters
    :nb_hidden_lines  # difference (filtered)

  # options can have
  # :only_holidays => true
  def initialize(project_id, options = {})
    @project    = Project.find(project_id)
    raise "could not find this project by id '#{project_id}'" if not @project
    @project_id = project_id
    @name       = @project.name

    # calculate lines
    cond = ""
    cond += " and wl_type=300" if options[:only_holidays] == true
    @wl_lines           = WlLine.find(:all, :conditions=>["project_id=?"+cond, project_id], :include=>["request","sdp_task","project"]).sort_by{|l| [l.wl_type, (l.person ? l.person.name : l.display_name)]}
    group_by_persons    = WlLine.find(:all, :conditions=>["project_id=?"+cond, project_id], :include=>["request","sdp_task","project"], :group => "person_id")
    nb = 0
    if options[:group_by_person] == true
      persons_id    = []
      groupBy_lines = []
      @wl_lines.each_with_index do |l, index|
        if l.sdp_task
          nb += 1
        end
        # Create a line for each person
        if not(persons_id.include? l.person_id)
          persons_id.push(l.person_id)
          if person_is_uniq?(l.person_id, @wl_lines)
            # person appears only once in all the lines
            groupBy_lines << l
            
          else
            # person appears seveal times in all the lines
            line = WlLine.new
            init_line(line, l.name, l.person_id, l.wl_type, l.wl_loads)
            groupBy_lines << line

          end
        else # Update each line for each person with multiple lines
          selected_line           = groupBy_lines.select{|t| t.person_id==l.person_id}.first
          selected_line.name      += " + " + l.name
          selected_line.wl_type   = ApplicationController::WL_LINE_CONSOLIDATED
          selected_line.wl_loads  += l.wl_loads  
          if selected_line.sdp_task
            
            if  l.sdp_task 
              #selected_line.sdp_task.initial   += l.sdp_task.initial
              #selected_line.sdp_task.balancei  += l.sdp_task.balancei
              #selected_line.sdp_task.remaining += l.sdp_task.remaining
              
            else
              #selected_line.sdp_task = SDPTask.select{|sdp| sdp==l.sdp_task}.first
              #selected_line.sdp_task.initial   = l.sdp_task.initial
              #selected_line.sdp_task.balancei  = l.sdp_task.balancei
              #selected_line.sdp_task.remaining = l.sdp_task.remaining
            end
          end

        end
      end
      max = groupBy_lines.select { |l| l.wl_type != 500}.map{ |l| l.id}.max + 1
      groupBy_lines.select { |l| l.wl_type == 500}.each_with_index { |l, index| 
        l.id = max + index
        }
      @wl_lines = groupBy_lines
    end 
    #raise "nb=#{nb}"
    #result = []
    #for l in @wl_lines
     # if l.sdp_task
     #   result << l.sdp_task.initial 
     #   result  << " | "
     # end
    #end
      #l.sdp_task.initial
      #l.sdp_task.balancei
      #l.sdp_task.remaining
    #raise "#{result}"
    Rails.logger.debug "\n===== hide_lines_with_no_workload: #{options[:hide_lines_with_no_workload]}\n\n"
    # no need to add a holidays line in DB for a projet. It will be consolidated at running time
    #if options[:only_holidays] != true
    #  @wl_lines  << WlLine.create(:name=>"Holidays", :request_id=>nil, :project_id=>project_id, :wl_type=>WorkloadsController::WL_LINE_HOLIDAYS) if @wl_lines.size == 0
    #end
    @nb_total_lines = @wl_lines.size
    # must be after the preceding test as we suppress line and if wl_lines.size is 0 then we create a new Holidays line
    if options[:hide_lines_with_no_workload]
      @displayed_lines = @wl_lines.select{|l| l.near_workload > 0}
    else
      @displayed_lines = @wl_lines
    end
    @nb_current_lines = @displayed_lines.size
    @nb_hidden_lines  = @nb_total_lines - @nb_current_lines
    from_day    = Date.today - (Date.today.cwday-1).days
    farest_week = wlweek(from_day+APP_CONFIG['workloads_months'].to_i.months)
    @wl_weeks   = []
    @weeks      = []
    @opens      = []
    @ctotals    = []
    @cprodtotals= []
    @availability = []
    @percents   = []
    @months     = []
    @days       = []
    month = Date::ABBR_MONTHNAMES[(from_day+4.days).month]
    month_displayed = false
    nb = 0
    iteration                   = from_day
    @next_month_percents        = 0.0
    @three_next_months_percents = 0.0
    @sum_availability           = 0
    while true
      w = wlweek(iteration) # output: year + week ("201143")
      break if w > farest_week or nb > 36*4
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
      @opens    << 5*group_by_persons.size - WlHoliday.get_from_week(w)*group_by_persons.size
      if @wl_lines.size > 0
        col_sum = col_sum(w, @wl_lines)
        @ctotals        << {:name=>'ctotal', :id=>w, :value=>col_sum}
        @cprodtotals    << {:id=>w, :value=>col_prod_sum(w, @wl_lines)}
        if @opens and @opens.last > 0
          percent = (@ctotals.last[:value] / @opens.last)*100
        else
          percent = 100
        end
        open    = @opens.last
        avail   = [0,(open-col_sum)].max
        if open > 0
          avail_percent = (avail/open).round
        else
          avail_percent = 0
        end
        @availability   << {:name=>'avail',:id=>w, :avail=>avail, :value=>(avail==0 ? '' : avail), :percent=>avail_percent}
        @sum_availability += (avail==0 ? '' : avail).to_f if nb<=8
        @next_month_percents += percent if nb < 5
        @three_next_months_percents += percent if nb >= 0 and nb < 0+12 # if nb >= 5 and nb < 5+12 # 28-Mar-2012: changed
        @percents << {:name=>'cpercent', :id=>w, :value=>percent.round.to_s+"%", :precise=>percent}
      end
      iteration = iteration + 7.days
      nb += 1
    end
    @next_month_percents        = (@next_month_percents / 5).round
    @three_next_months_percents = (@three_next_months_percents / 12).round

    # sum the lines
    @line_sums            = Hash.new
    today_week            = wlweek(Date.today)
    @total                = 0
    @planned_total        = 0
    @sdp_remaining_total  = 0
    @to_be_validated_in_wl_remaining_total = 0
    for l in @wl_lines
      @line_sums[l.id] = Hash.new
      #@line_sums[l.id][:sums] = l.wl_loads.map{|load| (load.week < today_week ? 0 : load.wlload)}.inject(:+)
      
      @line_sums[l.id][:sums] = l.planned_sum
      
      @total          += l.sum.to_f if l.wl_type <= 200 or l.wl_type == 500
      @planned_total  += @line_sums[l.id][:sums] if (l.wl_type <= 200 or l.wl_type == 500) and @line_sums[l.id][:sums]

      if l.sdp_task
        @sdp_remaining_total += l.sdp_task.remaining.to_f
        @line_sums[l.id][:init]      = l.sdp_task.initial
        @line_sums[l.id][:balance]   = l.sdp_task.balancei
        @line_sums[l.id][:remaining] = l.sdp_task.remaining
      elsif l.request
        s = round_to_hour(l.request.workload2)
        if l.request.sdp == "No"
          @line_sums[l.id][:init]      = 'no sdp'
          @line_sums[l.id][:balance]   = 'N/A'
          @line_sums[l.id][:remaining] = s
          @sdp_remaining_total        += s
          @to_be_validated_in_wl_remaining_total += s
        else
          r = l.request.sdp_tasks_remaining_sum({:trigram=>@project.trigram})
          #r = s if r == 0.0
          @line_sums[l.id][:init]      = l.request.sdp_tasks_initial_sum({:trigram=>l.project.trigram})
          @line_sums[l.id][:balance]   = l.request.sdp_tasks_balancei_sum({:trigram=>l.project.trigram})
          @line_sums[l.id][:remaining] = r
          @sdp_remaining_total        += r
        end
      else
        @line_sums[l.id][:init]      = 0.0
        @line_sums[l.id][:remaining] = 0.0
        @line_sums[l.id][:balancei]  = 0.0
      end
    end

  end

  def col_sum(w, wl_lines)
    wl_lines.map{|l| l.get_load_by_week(w)}.inject(:+)
  end

  def col_prod_sum(w, wl_lines)
    wl_lines.select{|l| l.wl_type==100}.map{|l| l.get_load_by_week(w)}.inject(:+)
  end

  # not DRY (already in application_controller)
  def round_to_hour(f)
    (f/0.125).round*0.125
  end

  def remain_to_plan_days
    @sdp_remaining_total - @planned_total
  end

  # Will generate a hash of hash following this format :
  # lines_by_stream[stream.id]["prev"]        = Previsional total (QS + Spider) for this stream
  # lines_by_stream[stream.id]["sum"]         = Total of imputation (QS + Spider) for this stream
  # lines_by_stream[stream.id]["qs_prev"]     = Previsional load for QS of this stream
  # lines_by_stream[stream.id]["qs_sum"]      = Total of imputation for QS of this stream
  # lines_by_stream[stream.id]["spider_prev"] = Previsional load for Spider of this stream
  # lines_by_stream[stream.id]["spider_sum"]  = Total of imputation for Spider of this stream
  def get_qr_qwr_wl_lines_by_streams
    lines_by_streams = Hash.new
    # Create arrays for each stream
    Stream.find(:all).each do |s|
      # lines_by_streams[s.id]                = Array.new
      lines_by_streams[s.id]                = Hash.new
      lines_by_streams[s.id]["prev"]        = 0
      lines_by_streams[s.id]["sum"]         = 0
      lines_by_streams[s.id]["qs_prev"]     = 0
      lines_by_streams[s.id]["spider_prev"] = 0
      lines_by_streams[s.id]["qs_sum"]      = 0
      lines_by_streams[s.id]["spider_sum"]  = 0
    end
    # Add wl_lines to corresponding stream
    wl_lines.each { |wl|
      if wl.project
        # Stream
        s = Stream.find_with_workstream(wl.project.workstream)
        # Previsional
        if(wl.wl_type == 110)
          lines_by_streams[s.id]["prev"]        = lines_by_streams[s.id]["prev"]    + (wl.project.calcul_qs_previsional.to_f * APP_CONFIG['qs_load'].to_f)
          lines_by_streams[s.id]["qs_prev"]     = lines_by_streams[s.id]["qs_prev"] + (wl.project.calcul_qs_previsional.to_f * APP_CONFIG['qs_load'].to_f)
          lines_by_streams[s.id]["qs_sum"]      = lines_by_streams[s.id]["qs_sum"]  + wl.planned_sum.to_f
          lines_by_streams[s.id]["sum"]         = lines_by_streams[s.id]["sum"]     + wl.planned_sum.to_f
        elsif(wl.wl_type == 120)
          lines_by_streams[s.id]["prev"]        = lines_by_streams[s.id]["prev"]        + (wl.project.calcul_spider_previsional.to_f * APP_CONFIG['spider_load'].to_f)
          lines_by_streams[s.id]["spider_prev"] = lines_by_streams[s.id]["spider_prev"] + (wl.project.calcul_spider_previsional.to_f * APP_CONFIG['spider_load'].to_f)
          lines_by_streams[s.id]["spider_sum"]  = lines_by_streams[s.id]["spider_sum"]  + wl.planned_sum.to_f
          lines_by_streams[s.id]["sum"]         = lines_by_streams[s.id]["sum"]         + wl.planned_sum.to_f
        end
      end
    }
    return lines_by_streams
  end

private

  def init_line(line, name, person_id, wl_type, wl_loads)
    line.name = name
    line.person= Person.find_by_id(person_id)
    line.wl_type = wl_type
    line.wl_loads = wl_loads
  end
  def person_is_uniq?(person_id, lines)
    ( lines.select{|l| l.person_id == person_id}.size ) == 1
  end
end

