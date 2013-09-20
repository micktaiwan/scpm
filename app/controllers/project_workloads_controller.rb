class ProjectWorkloadsController < ApplicationController
	layout 'pdc'

  before_filter :require_login
  before_filter :require_admin

  def index
    project_ids    = params[:project_ids]
    companies_ids  = params[:companies_ids]
    iterations_ids = params[:iterations_ids]
    tags_ids       = params[:tags_ids]
    if project_ids
      if project_ids.class==Array
        session['workload_project_ids'] = project_ids # array of strings
      else
        session['workload_project_ids'] = [project_ids] # array with one string
      end
    else
      if session['workload_project_ids'] == nil or session['workload_project_ids'] == ''
        session['workload_project_ids'] = []
      end
    end
    if companies_ids
      if companies_ids.class==Array
        session['workload_companies_ids'] = companies_ids # array of strings
      else
        session['workload_companies_ids'] = [companies_ids] # array with one string
      end
    else
      if session['workload_companies_ids'] == nil or session['workload_companies_ids'] == ''
        session['workload_companies_ids'] = []
      end
    end
    session['workload_iterations'] = []
    if iterations_ids
      iterations_ids.each do |i|
        iteration       = Iteration.find(i)
        iteration_name  = iteration.name
        project_code    = iteration.project_code
        project_id      = iteration.project.id
        session['workload_iterations'] << {:name=>iteration_name, :project_code=>project_code, :project_id=>project_id}
      end
    end
    session['workload_tags'] = []
    if tags_ids
      if tags_ids.class==Array
        session['workload_tags'] = tags_ids # array of strings
      else
        session['workload_tags'] = [tags_ids] # array with one string
      end
    end
    @projects = Project.find(:all, :conditions=>"project_id is null", :order=>"name")
    return if not session['workload_project_ids'] or session['workload_project_ids']==[]

    if @projects.size > 0
      session['workload_project_ids'] = [@projects.first.id] if not session['workload_project_ids']
    else
      render(:text=>'no project at all... Please create a new project.')
      return
    end
    @project_options = @projects.map {|p| ["#{p.name} (#{p.wl_lines.size})", p.id]}
    get_common_data(session['workload_project_ids'],session['workload_companies_ids'],session['workload_iterations'],session['workload_tags'])
    get_last_sdp_update
  end

  

  def change_workload(project_ids=nil)
    project_ids = params[:project_ids]

    if project_ids
      session['workload_project_ids'] = project_ids
    else
      session['workload_project_ids'] = []
    end

    companies_ids = params[:companies_ids]
    if companies_ids
      session['workload_companies_ids'] = companies_ids
    else
      session['workload_companies_ids'] = []
    end

    @projects = Project.find(:all, :conditions=>"project_id is null", :order=>"name")
    if not session['workload_project_ids'] or session['workload_project_ids']==[]
      return
    end

    if @projects.size > 0
      session['workload_project_ids'] = [@projects.first.id] if not session['workload_project_ids']
      # or not Project.find_by_id(session['workload_project_ids'])
    else
      render(:text=>'no project at all... Please create a new project.')
      return
    end
    @project_options = @projects.map {|p| ["#{p.name} (#{p.wl_lines.size})", p.id]}
    get_common_data(session['workload_project_ids'],session['workload_companies_ids'],session['workload_iterations'],session['workload_tags'])
  end

  def add_a_person
    person_id     = params[:person_id]
    project_ids   = params[:project_ids]
    companies_ids = params[:companies_ids]
    project_ids   = session['workload_project_ids'] if project_ids.nil?
    companies_ids = session['workload_companies_ids'] if companies_ids.nil?
    found         = WlLine.find(:all, :conditions=>["person_id=#{person_id} and project_id=#{project_ids[0]}"])
    person_name   = Person.find(person_id).name
    project_name  = Project.find(project_ids[0]).name
    if found.empty?
      @line = WlLine.create(:name=>project_name , :project_id=>project_ids[0], :request_id=>nil, :person_id=>person_id, :wl_type=>WL_LINE_OTHER)
      get_common_data(project_ids,companies_ids,session['workload_iterations'],session['workload_tags']) 
    else
      @error = "This line already exists: #{person_name}"
    end
  end

  def hide_lines_with_no_workload
    on = (params[:on].to_s != 'false')
    session['workload_hide_lines_with_no_workload'] = on
    get_common_data(session['workload_project_ids'],session['workload_companies_ids'],session['workload_iterations'],session['workload_tags'])
  end

  def group_by_person
    on = (params[:on].to_s != 'false')
    session['group_by_person'] = on
    get_common_data(session['workload_project_ids'],session['workload_companies_ids'],session['workload_iterations'],session['workload_tags'])
  end

  def xml_export
    begin
      @xml = Builder::XmlMarkup.new(:indent => 1)

      @workload = ProjectWorkload.new(session['workload_project_ids'],session['workload_companies_ids'],session['workload_iterations'],session['workload_tags'], {:hide_lines_with_no_workload => session['workload_hide_lines_with_no_workload'].to_s=='true', :group_by_person => session['group_by_person'].to_s=='true'})
      
      # MONTHS EXPORT
      @months = ["#{@workload.names}","","", "", "", "","",""]
      @months << "" if APP_CONFIG['workloads_display_consumed_column']
      for i in @workload.months
        @months << i
      end
      
      # WEEKS EXPORT
      @weeks = ["","","","","","","",""]
      @weeks << "" if APP_CONFIG['workloads_display_consumed_column']
      for i in @workload.weeks
        @weeks << i
      end

      # DAYS EXPORT
      @days = ["","","","Init.","Gain","Rem.","Planned","Total"]
      @days = @days[0..3]+["Cons."]+@days[4..7] if APP_CONFIG['workloads_display_consumed_column']
      for i in @workload.days
        @days << i
      end

      # OPENS EXPORT
      @opens = ["","Nb of worked days","","","","","",""]
      @opens << "" if APP_CONFIG['workloads_display_consumed_column']
      for i in @workload.opens
        @opens << i
      end

      # CTOTALS EXPORT
      @ctotals = ["","Total","","","","","",""]
      @ctotals << "" if APP_CONFIG['workloads_display_consumed_column']
      for i in @workload.ctotals
        @ctotals << i[:value]
      end

      # SUMS / PERCENTS EXPORT
      @sums_percents = ["","Sums / Percents","",""]
      @sums_percents << @workload.sdp_consumed_total if APP_CONFIG['workloads_display_consumed_column']
      @sums_percents << ""
      @sums_percents << @workload.sdp_remaining_total
      @sums_percents << @workload.planned_total
      @sums_percents << @workload.total
      for i in @workload.percents
        @sums_percents << i[:value]
      end

      # AVAILABILITY EXPORT
      @availability = ["","Availability (Sum for the 2 next months)","","","",""]
      @availability << "" if APP_CONFIG['workloads_display_consumed_column']
      @availability << @workload.sum_availability
      @availability << ""
      for i in @workload.availability
        @availability << i[:value]
      end

      # WORKLOADS EXPORT
      @lines          = []
      @virtual        = Hash.new
      @line_countable = Hash.new
      @error          = Hash.new
      line_pos        = 0
      for l in @workload.wl_lines
        line_pos += 1
        if l.person and l.person.is_virtual == 1
          @virtual[line_pos] = true
        else
          @virtual[line_pos] = false
        end
        if l.wl_type <= 200 or l.wl_type == 500
          @line_countable[line_pos] = true
        else
          @line_countable[line_pos] = false
        end

        planned_total = @workload.line_sums[l.id][:sums].to_f       
        remaining     = @workload.line_sums[l.id][:remaining].to_f
        consumed      = @workload.line_sums[l.id][:consumed].to_f if APP_CONFIG['workloads_display_consumed_column']
        if (( l.wl_type == 100 or l.wl_type == 200 or l.wl_type == 500) and ((planned_total/remaining < 0.9) or (planned_total/remaining > 1.1) or (planned_total-remaining).abs > 3))
          @error[line_pos] = true
        else
          @error[line_pos] = false
        end
     
        line = []
        if session['group_by_person'].to_s=='true'
          line << Company.find(Person.find(l.person_id).company_id).name
        else
          line << l.person.company.name
        end
        line << l.person.name
        line << l.name
        line << @workload.line_sums[l.id][:init]
        line << @workload.line_sums[l.id][:consumed] if APP_CONFIG['workloads_display_consumed_column']
        line << @workload.line_sums[l.id][:balance]
        line << @workload.line_sums[l.id][:remaining]
        line << @workload.line_sums[l.id][:sums]
        line << l.sum
        for week in @workload.wl_weeks
          workload = l.get_load_by_week(week)
          line << workload
        end
         @lines << line
      end
      headers['Content-Type']         = "application/vnd.ms-excel"
      headers['Content-Disposition']  = 'attachment; filename="project_workload.xls"'
      headers['Cache-Control']        = ''
      render(:layout=>false)
    end
  end
  def update_color_task
    id    = params[:id].to_i
    color = params[:color] 
    task  = Task.find(id)
    task.color = color
    task.save
    render(:nothing=>true)
  end
  def destroy_line
    @wl_line_id     = params[:id]
    wl_line         = WlLine.find(@wl_line_id)
    wl_line.destroy
    WlLineTask.find(:all, :conditions=>["wl_line_id=?",@wl_line_id]).each do |l|
      l.destroy
    end
    line_tags = LineTag.find(:all, :conditions=>["line_id=#{@wl_line_id}"])
    tags = []
    line_tags.each do |l|
      tag = Tag.find(l.tag_id)
      tags <<  tag if !tags.include?(tag) 
    end
    line_tags.each do |l|
      l.destroy
    end
    tags.each do |t|
      t.destroy if LineTag.find(:all, :conditions=>["tag_id=#{t.id}"]).size == 0 
    end
  end

private

  def get_common_data(project_ids, companies_ids, iterations, tags_ids)
    @people   = Person.find(:all, :conditions=>"has_left=0", :order=>"name").map {|p| ["#{p.name}", p.id]}
    @workload = ProjectWorkload.new(project_ids, companies_ids, iterations,tags_ids, {:hide_lines_with_no_workload => session['workload_hide_lines_with_no_workload'].to_s=='true', :group_by_person => session['group_by_person'].to_s=='true'})
  end

  def get_last_sdp_update
    @last_sdp_phase = SDPPhase.find(:first, :order=>'updated_at desc')
    if @last_sdp_phase != nil
      @last_sdp_update = @last_sdp_phase.updated_at
    else
      @last_sdp_update = nil
    end
  end

  def require_admin
    if !current_user.has_role?('Admin') and !current_user.has_role?('ServiceLineResp')
      render(:text=>"You're not allowed to view this page. This is sad.")
      return
    end
  end

end
