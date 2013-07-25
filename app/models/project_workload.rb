class VirtualWlLine < WlLine

  attr_accessor :projects

  def initialize
    super
    @projects = Array.new
  end

end


class ProjectWorkload

  include ApplicationHelper

  attr_reader :names,  # projects names
    :weeks,           # arrays of week's names '43', '44', ...
    :wl_weeks,        # array of week ids '201143'
    :months,          # "Oct"
    :days,            # week days display per week: "17-21"
    :opens,           # total of worked days per week (5 - nb of holidays)
    :project,
    :project_ids,
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

  # options can be
  # :only_holidays => true
  # :group_by_person => true
  # :hide_lines_with_no_workload => true
  def initialize(project_ids, options = {})
    #Rails.logger.debug "\n===== only_holidays: #{options[:only_holidays]}"
    #Rails.logger.debug "\n===== group_by_person: #{options[:group_by_person]}"
    #Rails.logger.debug "\n===== group_by_person: #{options[:group_by_person]}\n\n"
    #@project    = Project.find(project_id)
    #raise "could not find this project by id '#{project_id}'" if not @project
    #@project_id = project_id
    #raise "#{project_ids.type}"

    # calculate lines
    cond = ""
    cond += " and wl_type=300" if options[:only_holidays] == true
    #raise "#{project_ids.join(',')}"
    @names = project_ids.map{ |id| Project.find(id).name}.join(', ')
    @wl_lines           = WlLine.find(:all, :conditions=>["project_id in (#{project_ids.join(',')})"+cond], :include=>["request","sdp_task","project"]).sort_by{|l| [l.wl_type, (l.person ? l.person.name : l.display_name)]}
    uniq_person_number = @wl_lines.map{|l| l.person_id}.uniq.size
    #group_by_persons    = WlLine.find(:all, :conditions=>["project_id in (#{project_ids.join(',')})"+cond], :include=>["request","sdp_task","project"], :group => "person_id")
  
    if options[:group_by_person]
      persons_id    = []
      groupBy_lines = []
      person_task = Hash.new 
      @wl_lines.each_with_index do |l, index|
        if not(persons_id.include? l.person_id) # Create a line for each person
          persons_id.push(l.person_id)
          if person_is_uniq?(l.person_id, @wl_lines) # person appears only once in all the lines
            groupBy_lines << l
          else # person appears several times in all the lines
            line = VirtualWlLine.new
            workloads = l.wl_loads
            init_line(line, l.name, l.person_id, l.wl_type, l.wl_loads, l.project)
            groupBy_lines << line
          end
          person_task[l.person_id] = Hash.new
          if l.sdp_task
            person_task[l.person_id][:initial]   = l.sdp_task.initial.to_f   #if l.sdp_task.initial
            person_task[l.person_id][:balancei]  = l.sdp_task.balancei.to_f  #if l.sdp_task.balancei
            person_task[l.person_id][:remaining] = l.sdp_task.remaining.to_f #if l.sdp_task.remaining
          else
            person_task[l.person_id][:initial]   = 0.0
            person_task[l.person_id][:balancei]  = 0.0
            person_task[l.person_id][:remaining] = 0.0
          end        
        else # Update each line for each person with multiple lines
          selected_line           =  groupBy_lines.select{|t| t.person_id==l.person_id}.first
          #selected_line.name      += " + " + l.name
          selected_line.projects << l.project if not selected_line.projects.include?(l.project)
          selected_line.wl_type   =  ApplicationController::WL_LINE_CONSOLIDATED
          selected_line.wl_loads  += l.wl_loads
          if l.sdp_task 
            person_task[l.person_id][:initial]   += l.sdp_task.initial.to_f
            person_task[l.person_id][:balancei]  += l.sdp_task.balancei.to_f
            person_task[l.person_id][:remaining] += l.sdp_task.remaining.to_f
          end
        end
      end
      max = groupBy_lines.select { |l| l.wl_type != 500}.map{ |l| l.id}.max || 0 + 1
      groupBy_lines.select { |l| l.wl_type == 500}.each_with_index { |l, index| 
        l.id = max + index
        }
      @wl_lines = groupBy_lines
    end 

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
    week_counter = 0
    iteration                   = from_day
    @next_month_percents        = 0.0
    @three_next_months_percents = 0.0
    @sum_availability           = 0
    while true
      w = wlweek(iteration) # output: year + week ("201143")
      break if w > farest_week or week_counter > 36*4
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
      @opens    << 5*uniq_person_number - WlHoliday.get_from_week(w)*uniq_person_number
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
        @sum_availability += (avail==0 ? '' : avail).to_f if week_counter<=8
        @next_month_percents += percent if week_counter < 5
        @three_next_months_percents += percent if week_counter >= 0 and week_counter < 0+12 # if week_counter >= 5 and week_counter < 5+12 # 28-Mar-2012: changed
        @percents << {:name=>'cpercent', :id=>w, :value=>percent.round.to_s+"%", :precise=>percent}
      end
      iteration    += 7.days
      week_counter += 1
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

      if (options[:group_by_person])
        @sdp_remaining_total        += person_task[l.person_id][:remaining]
        @line_sums[l.id][:init]      = person_task[l.person_id][:initial]
        @line_sums[l.id][:balance]   = person_task[l.person_id][:balancei]
        @line_sums[l.id][:remaining] = person_task[l.person_id][:remaining]

      elsif l.sdp_task
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
          r = l.request.sdp_tasks_remaining_sum()#{:trigram=>@project.trigram})
          #r = s if r == 0.0
          @line_sums[l.id][:init]      = l.request.sdp_tasks_initial_sum()#{:trigram=>l.project.trigram})
          @line_sums[l.id][:balance]   = l.request.sdp_tasks_balancei_sum()#{:trigram=>l.project.trigram})
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

  # FIXME: not DRY (already in application_controller)
  def round_to_hour(f)
    (f/0.125).round*0.125
  end

  def remain_to_plan_days
    @sdp_remaining_total - @planned_total
  end

private

  def init_line(line, name, person_id, wl_type, wl_loads, project)
    line.name     = "(grouped)" #name
    line.person   = Person.find_by_id(person_id)
    line.wl_type  = wl_type
    line.wl_loads = wl_loads
    line.projects = [project]
  end
  
  def person_is_uniq?(person_id, lines)
    ( lines.select{|l| l.person_id == person_id}.size ) == 1
  end
end

