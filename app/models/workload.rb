class Workload

  include ApplicationHelper

  attr_reader :name, :weeks, :wl_weeks, :person_id, :wl_lines, :line_sums,
              :opens, :ctotals, :cprodtotals, :percents, :months, :days, :person, :next_month_percents, :three_next_months_percents,
              :planned_total, :sdp_remaining_total

  def initialize(person_id, options = {})
    @person     = Person.find(person_id)
    raise "could not find this person by id '#{person_id}'" if not @person
    @person_id  = person_id
    @name       = @person.name

    # calculate lines
    cond = ""
    cond += " and wl_type=300" if options[:only_holidays] == true
    @wl_lines   = WlLine.find(:all, :conditions=>["person_id=?"+cond, person_id], :include=>["request","sdp_task","person"], :order=>"wl_type, name")
    if options[:only_holidays] != true
      @wl_lines  << WlLine.create(:name=>"Cong&eacute;s", :request_id=>nil, :person_id=>person_id, :wl_type=>WorkloadsController::WL_LINE_HOLIDAYS) if @wl_lines.size == 0
    end
    from_day    = Date.today - (Date.today.cwday-1).days
    #farest_week = @wl_lines.map{|l| m = l.wl_loads.map{|l| l.week}.max; m ? m:0}.max
    farest_week = wlweek(from_day+6.months) # if farest_week == 0
    @wl_weeks   = []
    @weeks      = []
    @opens      = []
    @ctotals    = [] # total days planned including not project days (holidays and other lines)
    @cprodtotals= [] # total days planned on production only
    @percents   = []
    @months     = []
    @days       = []
    month = Date::ABBR_MONTHNAMES[(from_day+4.days).month]
    month_displayed = false
    nb = 0
    iteration = from_day
    @next_month_percents = 0.0
    @three_next_months_percents = 0.0
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
        @ctotals      << {:name=>'ctotal',    :id=>w, :value=>col_sum(w, @wl_lines)}
        @cprodtotals  << {:name=>'cprodtotal',:id=>w, :value=>col_prod_sum(w, @wl_lines)}
        percent = (@ctotals.last[:value] / @opens.last)*100
        @next_month_percents += percent if nb < 5
        @three_next_months_percents += percent if nb >= 5 and nb <= 12+4
        @percents << {:name=>'cpercent', :id=>w, :value=>percent.round.to_s+"%", :precise=>percent}
      end
      iteration = iteration + 7.days
      nb += 1
    end
    @next_month_percents = (@next_month_percents / 5).round
    @three_next_months_percents = (@three_next_months_percents / 12).round

    # sum the lines
    @line_sums      = Hash.new
    today_week      = wlweek(Date.today)
    @planned_total  = 0
    @sdp_remaining_total = 0
    for l in @wl_lines
      @line_sums[l.id] = Hash.new
      @line_sums[l.id][:sums] = l.wl_loads.map{|load| (load.week < today_week ? 0 : load.wlload)}.inject(:+)
      @planned_total  += @line_sums[l.id][:sums] if l.wl_type <= 200 and @line_sums[l.id][:sums]
      if l.sdp_task
        @sdp_remaining_total += l.sdp_task.remaining
        @line_sums[l.id][:init]      = l.sdp_task.initial
        @line_sums[l.id][:balance]   = l.sdp_task.balancei
        @line_sums[l.id][:remaining] = l.sdp_task.remaining
      elsif l.request
        if l.request.status == "to be validated"
          s = round_to_hour(l.request.workload2 * 0.8)
          @sdp_remaining_total        += s
          @line_sums[l.id][:init]      = s
          @line_sums[l.id][:balance]   = s
          @line_sums[l.id][:remaining] = s
        else
          @sdp_remaining_total += l.request.sdp_tasks_remaining_sum({:trigram=>@person.trigram})
          @line_sums[l.id][:init]      = l.request.sdp_tasks_initial_sum({:trigram=>l.person.trigram})
          @line_sums[l.id][:balance]   = l.request.sdp_tasks_balancei_sum({:trigram=>l.person.trigram})
          @line_sums[l.id][:remaining] = l.request.sdp_tasks_remaining_sum({:trigram=>l.person.trigram})
        end
      else
        @line_sums[l.id][:init]      = ""
        @line_sums[l.id][:remaining] = ""
        @line_sums[l.id][:balancei]  = ""
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

end

