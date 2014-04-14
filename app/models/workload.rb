class Workload

  include ApplicationHelper, WorkloadPlanningsHelper

  attr_reader :name,  # person's name
    :names,           # Filtre's projects names
    :weeks,           # arrays of week's names '43', '44', ...
    :wl_weeks,        # array of week ids '201143'
    :months,          # "Oct"
    :days,            # week days display per week: "17-21"
    :opens,           # total of worked days per week (5 - nb of holidays)
    :person,
    :person_id,
    :projects,
    :planning_tasks,
    :wl_lines,        # arrays of loads, all lines (filtered and not filtered)
    :displayed_lines, # only filtered lines
    :line_sums,       # sum of days per line of workload
    :ctotals,         # total days planned per week including not bundle days (holidays and other lines) {:id=>w, :value=>col_sum(w, @wl_lines)}
    :availability,    # total days of availability {:days=>xxx, :percent=>yyy}
    :sum_availability,# sum of availabity days for the next 8 weeks
    :cprodtotals,     # total days planned per week on production only {:id=>w, :value=>col_prod_sum(w, @wl_lines)}
    :percents,        # total percent per week: {:name=>'cpercent', :id=>w, :display=>percent.round.to_s+"%", :value=>percent}
    :next_month_percents,         # next 5 weeks capped (including current)
    :three_next_months_percents,  # next 3 months capped (was _after_ the 5 coming weeks but changed later including next 5 weeks)
    :total,                       # total number of days planned (including past weeks)
    :planned_total,               # total number of days planned (current week and after)
    :sdp_consumed_total,          # SDP consumed, including requests to be validated (non SDP task)
    :sdp_remaining_total,         # SDP remaining, including requests to be validated (non SDP task)
    :to_be_validated_in_wl_remaining_total, # total of requests to be validated planned in workloads
    :nb_total_lines,  # total before filters
    :nb_current_lines,# total after filters
    :nb_hidden_lines, # difference (filtered)
    :staffing         # nb of person needed per week

  # options can have
  # :only_holidays => true
  def initialize(person_id, project_ids, iterations, tags_ids, options = {})

    # return if project_ids.size==0
    @person     = Person.find(person_id)
    raise "could not find this person by id '#{person_id}'" if not @person
    @projects = Project.find(:all, :conditions=>["id in (#{project_ids.join(',')})"]) if project_ids.size!=0
    @projects = WlLine.find(:all, :conditions=>["person_id=#{person_id} and project_id is not null"]).collect{|l| Project.find(l.project_id)}.uniq if project_ids.size==0
    @person_id  = person_id
    @name       = @person.name

    # calculate lines
    cond = ""
    cond += " and wl_type=300" if options[:only_holidays] == true

    if iterations.size == 0
      @names      = project_ids.map{ |id| Project.find(id).name}.join(', ')
    else
      @names      = ""
      cpt         = 0
      project_ids.each do |id|
        cpt     = cpt+1
        @names  << Project.find(id).name
        @names  << "[" if iterations.map{|i|i[:project_id].to_s}.include? id
        comma   = false
        iterations.each do |i|
          if id == i[:project_id].to_s
            @names << ", " if comma
            @names << i[:name]
            comma   = true
          end
        end
        @names << "]"  if iterations.map{|i|i[:project_id].to_s}.include? id
        @names << ", " if cpt < project_ids.length
      end
    end
    # Case: no project selected
    if !project_ids or project_ids.size==0
      @wl_lines   = WlLine.find(:all, :conditions=>["person_id=#{person_id}"+cond], :include=>["request","wl_line_task","person"], :order=>APP_CONFIG['project_workloads_lines_sort'])
    else
    # Case: at least, one project selected
    # No iteration selected
      if iterations.size==0
        @wl_lines   = WlLine.find(:all, :conditions=>["project_id in (#{project_ids.join(',')})"+cond+" and person_id=#{person_id}"], :include=>["request","wl_line_task","person"], :order=>APP_CONFIG['project_workloads_lines_sort'])
      else
    # at least, one iteration selected
        project_ids_without_iterations  =[]     # Array which contains ids of projects we don't want to filter with iterations
        project_ids_with_iterations     =[]     # Array which contains ids of projects we want to filter with iterations
        project_ids.each do |p|
          project_ids_without_iterations << p
        end
        iterations.each do |i|
          if project_ids_without_iterations.include? i[:project_id].to_s
            project_ids_without_iterations.delete(i[:project_id].to_s)
            project_ids_with_iterations << i[:project_id].to_s
          end
        end
        # Generate lines without iterations
        if project_ids_without_iterations.size>0
          @wl_lines = WlLine.find(:all, :conditions=>["project_id in (#{project_ids_without_iterations.join(',')})"+cond+" and person_id=#{person_id}"], :include=>["request","wl_line_task","person"])
        else
          @wl_lines = []
        end

        # Generate lines with iterations
        if project_ids_with_iterations.size>0
          wl_lines_with_iteration = WlLine.find(:all, :conditions=>["project_id in (#{project_ids_with_iterations.join(',')})"+cond+" and person_id=#{person_id}"], :include=>["request","wl_line_task","person"])
          wl_lines_with_iteration.each do |l|
            add_line_condition = false
            if l.sdp_tasks
              line_iterations = []
              iterations.each do |i|
                if i[:project_id]==l.project_id
                  line_iterations << [i[:name],i[:project_code]]
                end
              end

              l.sdp_tasks.each do |s|
                add_line_condition = true if line_iterations.include? [s.iteration,s.project_code]
              end

            end
            # Line respecting conditions added to the workload lines
            @wl_lines << l if add_line_condition
          end
        end
      end
    end

    # Case: tags selected
    @wl_lines = @wl_lines.select{|l|l.tag_in(tags_ids) == true} if tags_ids.size > 0

    #Rails.logger.debug "\n===== hide_lines_with_no_workload: #{options[:hide_lines_with_no_workload]}\n\n"
    if options[:only_holidays] != true
      line_count = WlLine.find(:all, :conditions=>["person_id=#{person_id}"])
      if line_count.size == 0 or line_count.select {|l| l.wl_type==ApplicationController::WL_LINE_HOLIDAYS}.size == 0
        @wl_lines  << WlLine.create(:name=>"Holidays", :request_id=>nil, :person_id=>person_id, :wl_type=>ApplicationController::WL_LINE_HOLIDAYS)
      end
      if APP_CONFIG['automatic_except_line_addition']
        if line_count.size == 0 or line_count.select {|l| l.wl_type==ApplicationController::WL_LINE_EXCEPT and (l.name =~ /Other/)}.size == 0
          @wl_lines  << WlLine.create(:name=>"Other (out of #{APP_CONFIG['project_name']})", :request_id=>nil, :person_id=>person_id, :wl_type=>ApplicationController::WL_LINE_EXCEPT)
        end
        if line_count.size == 0 or line_count.select {|l| l.wl_type==ApplicationController::WL_LINE_EXCEPT and (l.name =~ /#{APP_CONFIG['project_name']} AVV/)}.size == 0
          @wl_lines  << WlLine.create(:name=>"#{APP_CONFIG['project_name']} AVV", :request_id=>nil, :person_id=>person_id, :wl_type=>ApplicationController::WL_LINE_EXCEPT)
        end
      end
    end
    @nb_total_lines = @wl_lines.size
    # must be after the preceding test as we suppress line and if wl_lines.size is 0 then we create a new Holidays line
    if options[:hide_lines_with_no_workload]
      @displayed_lines = @wl_lines.select{|l| l.near_workload > 0}
    else
      @displayed_lines = @wl_lines
    end
    @displayed_lines  = @displayed_lines.sort_by { |l| eval(APP_CONFIG['workloads_lines_sort'])}
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
    @staffing   = []
    month = Date::ABBR_MONTHNAMES[(from_day+4.days).month]
    month_displayed = false
    nb = 0
    iteration                   = from_day
    @next_month_percents        = 0.0
    @three_next_months_percents = 0.0
    @sum_availability           = 0
    while true
      w = wlweek(iteration) # output: year + week ("201143")
      break if w > farest_week or nb > 100*4
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
      company = Company.find_by_id(Person.find_by_id(person_id).company_id)
      raise "Company doesn't exist for this person" if company.nil?
      @opens    << 5 - WlHoliday.get_from_week_and_company(w,company)

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
        avail   = open-col_sum # [0,(open-col_sum)].max
        if open > 0
          avail_percent = (avail/open).round
        else
          avail_percent = 0
        end
        if person.is_virtual==1 and open > 0
          @staffing << col_sum / open
        else
          @staffing << 0
        end
        @availability   << {:name=>'avail',:id=>w, :value=>avail, :display=>(avail==0 ? '' : avail), :percent=>avail_percent}
        @sum_availability += (avail==0 ? '' : avail).to_f if nb<=8
        @next_month_percents += capped_if_option(percent) if nb < 5
        @three_next_months_percents += capped_if_option(percent) if nb >= 0 and nb < 0+12 # if nb >= 5 and nb < 5+12 # 28-Mar-2012: changed
        @percents << {:name=>'cpercent', :id=>w, :value=>percent, :display=>percent.round.to_s+"%"}
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
    @sdp_consumed_total   = 0
    @to_be_validated_in_wl_remaining_total = 0
    for l in @wl_lines
      @line_sums[l.id] = Hash.new
      #@line_sums[l.id][:sums] = l.wl_loads.map{|load| (load.week < today_week ? 0 : load.wlload)}.inject(:+)
      @line_sums[l.id][:sums] = l.planned_sum
      @total          += l.sum if l.wl_type <= 200
      @planned_total  += @line_sums[l.id][:sums] if l.wl_type <= 200 and @line_sums[l.id][:sums]
      if l.sdp_tasks.count > 0
        @sdp_remaining_total        += l.sdp_tasks_remaining.to_f
        @line_sums[l.id][:init]      = l.sdp_tasks_initial
        @line_sums[l.id][:balance]   = l.sdp_tasks_balancei
        @line_sums[l.id][:remaining] = l.sdp_tasks_remaining
        @line_sums[l.id][:consumed]  = l.sdp_tasks_consumed
        @sdp_consumed_total         += @line_sums[l.id][:consumed].to_f
      elsif l.request
        s = round_to_hour(l.request.workload2)
        if l.request.sdp == "No"
          @line_sums[l.id][:init]      = 'no sdp'
          @line_sums[l.id][:balance]   = 'N/A'
          @line_sums[l.id][:remaining] = s
          @sdp_remaining_total        += s
          @to_be_validated_in_wl_remaining_total += s
        else
          r = l.request.sdp_tasks_remaining_sum({:trigram=>@person.trigram})
          #r = s if r == 0.0
          @line_sums[l.id][:init]      = l.request.sdp_tasks_initial_sum({:trigram=>l.person.trigram})
          @line_sums[l.id][:balance]   = l.request.sdp_tasks_balancei_sum({:trigram=>l.person.trigram})
          @line_sums[l.id][:consumed]  = l.request.sdp_tasks_consumed_sum({:trigram=>l.person.trigram})
          @line_sums[l.id][:remaining] = r
          @sdp_remaining_total        += r
          @sdp_consumed_total         += @line_sums[l.id][:consumed]
        end
      else
        @line_sums[l.id][:init]      = 0.0
        @line_sums[l.id][:remaining] = 0.0
        @line_sums[l.id][:balancei]  = 0.0
        @line_sums[l.id][:consumed]  = 0.0
      end
    end
    @planning_tasks = get_plannings(@projects, wl_weeks)
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
      if wl.project and wl.project.workstream!=''
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

  def capped_if_option(percent)
    return [percent, 100].min if APP_CONFIG['consolidation_capped_next_weeks']
    percent
  end

end
