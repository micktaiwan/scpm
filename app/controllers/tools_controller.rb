require 'google_chart'

class ToolsController < ApplicationController

  layout 'tools'

  include WelcomeHelper

  NB_QR 					            = 24
  NB_FTE 					            = 20  # TODO: should be automatically calculated from workloads
  NB_DAYS_PER_MONTH			      = 18
  MEETINGS_LOAD_PER_MONTH 	  = 1
  PM_LOAD_PER_MONTH 		      = 48 #was: NB_DAYS_PER_MONTH*2 + NB_DAYS_PER_MONTH/1.5 # CP + PMO + DP
  WP_LEADERS_DAYS_PER_MONTH   = 12 #was: 18 # 10 + 4*2

  PM_PROVISION_ADJUSTMENT     = 0
  QA_PROVISION_ADJUSTMENT     = 22.5
  RK_PROVISION_ADJUSTMENT     = 21
  CI_PROVISION_ADJUSTMENT     = 53.5
  OP_PROVISION_ADJUSTMENT     = 0.5

  def index
  end

  def stats_open_projects
    @xml = Builder::XmlMarkup.new(:indent => 1)
    @stats = []
    # global stats
    tmp_projects  = Request.find(:all, :conditions=>"status !='cancelled' and status != 'to be validated'")
    @workpackages = tmp_projects.map{|r| r.project_name + " / " + get_workpackage_name_from_summary(r.summary, 'No WP')}.uniq.sort
    @projects     = tmp_projects.map{|r| r.project_name}.uniq.sort
    begin
      month_loop(5,2010) { |d|
        requests = Request.find(:all, :conditions=>"date_submitted <= '#{d.to_s}' and status!='to be validated' and status!='cancelled'")
        a = requests.size
        b = requests.map{|r| r.project_name}.uniq.size # work also with a simple group by clause
        c = requests.map{|r| r.project_name + " " + get_workpackage_name_from_summary(r.summary, 'No WP')}.uniq.size
        @stats << [d, a,b,c]
        }
    rescue Exception => e
      render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
      return
    end

    # by centres
    @centres = []
    for centre in ["EA", "EDE", "EV", "EDC", "EDG", "EDS", "EI", "EDY", "EM", "EMNB", "EMNC", "TBCE"] do
      stats = Array.new
      @centres << {:name=>centre, :stats=>stats}
      begin
        month_loop(5,2010) { |d|
          requests = Request.find(:all, :conditions=>"workstream='#{centre}' and date_submitted <= '#{d.to_s}' and status!='to be validated' and status!='cancelled'")
          a = requests.size
          b = requests.map{|r| r.project_name}.uniq.size # work also with a simple group by clause
          c = requests.map{|r| r.project_name + " " + get_workpackage_name_from_summary(r.summary, 'No WP')}.uniq.size

          stats << [d, a,b,c]
          }
      rescue Exception => e
        render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
        return
      end
      #puts "#{centre}: #{stats.size}"
    end
    headers['Content-Type'] = "application/vnd.ms-excel"
    headers['Content-Disposition'] = 'attachment; filename="Stats.xls"'
    headers['Cache-Control'] = ''
    render(:layout=>false)
  end

  def test_email
    Mailer::deliver_mail("mfaivremacon@sqli.com")
  end

  def sdp_import
  end

  def do_sdp_upload
    post = params[:upload]
    redirect_to '/tools/sdp_import' and return if post.nil? or post['datafile'].nil?
    name =  post['datafile'].original_filename
    directory = "public/data"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(post['datafile'].read) }
    sdp = SDP.new(path)
    sdp.import
    sdp_index_prepare
    SdpImportLog.create(
        :sdp_initial_balance             => @sdp_initial_balance,
        :sdp_real_balance                => @real_balance,
        :sdp_real_balance_and_provisions => @real_balance_and_provisions,
        :operational_total_minus_om      => @operational_total-@operational_percent_total,
        :not_included_remaining          => @not_included_remaining,
        :provisions                      => @provisions_remaining_should_be,
        :sold                            => @sold,
        :remaining_time                  => @remaining_time
        )
    sdp_graph # aleady in sdp_index_prepare, but repeated here so grap in email is updated
    history_comparison        
    body = render_to_string(:action=>'sdp_index', :layout=>false)
    Mailer::deliver_mail("mfaivremacon@sqli.com,vmudry@sqli.com,bmonteils@sqli.com","[EISQ] SDP update","<b>SDP has been updated by #{current_user.name}</b><br/><br/>"+body)
    redirect_to '/tools/sdp_index'
  end

  def sdp_index_prepare
    return if SDPTask.count.zero?
    begin
      @nb_qr                             = NB_QR
      @fte                               = NB_FTE
      @phases                            = SDPPhase.all
      @provisions                        = SDPTask.find(:all, :conditions=>"iteration='P'", :order=>'title')
      @sdp_initial_balance               = @phases.inject(0) { |sum, p| p.balancei+sum}
      tasks2010                          = SDPTask.find(:all, :conditions=>"iteration='2010'")
      tasks2011                          = SDPTask.find(:all, :conditions=>"iteration='2011'")
      tasks2012                          = SDPTask.find(:all, :conditions=>"iteration='2012'")
      op2010                             = tasks2010.inject(0) { |sum, t| t.initial+sum}
      op2011                             = tasks2011.inject(0) { |sum, t| t.initial+sum}
      op2012                             = tasks2012.inject(0) { |sum, t| t.initial+sum}
      @operational2011_10percent         = round_to_hour(op2011*0.11111111111)
      @operational2012_10percent         = round_to_hour(op2012*0.11111111111)
      @operational_percent_total         = @operational2011_10percent + @operational2012_10percent
      @operational_total_2011            = op2010 + op2011 + @operational2011_10percent
      @operational_total_2012            = op2012 + @operational2012_10percent
      @operational_total                 = @operational_total_2011 + @operational_total_2012
      @remaining                         = (tasks2010.inject(0) { |sum, t| t.remaining+sum} + tasks2011.inject(0) { |sum, t| t.remaining+sum})
      @remaining_time                    = (@remaining/NB_FTE/NB_DAYS_PER_MONTH/0.001).round * 0.001
      @phases.each { |p|  p.gain_percent = (p.initial==0) ? 0 : (p.balancei/p.initial*100/0.1).round * 0.1 }
      @theorical_management              = round_to_hour((PM_LOAD_PER_MONTH + MEETINGS_LOAD_PER_MONTH*NB_QR + WP_LEADERS_DAYS_PER_MONTH)*@remaining_time)
      montee                             = default_to_zero { SDPActivity.find_by_title('Montee en competences').remaining }
      souscharges                        = default_to_zero { SDPActivity.find_by_title('Sous charges').remaining }
      incidents                          = default_to_zero { SDPActivity.find_by_title('Incidents').remaining }
      init                               = default_to_zero { SDPActivity.find_by_title('Initialization').remaining }
      bmc_avv                            = default_to_zero { SDPActivity.find_by_title('AVV BMC and other').remaining }
      @remaining_management              = default_to_zero { SDPPhase.find_by_title('Bundle Management').remaining - (montee+souscharges+init+bmc_avv+incidents) }
      @ci_remaining                      = default_to_zero { SDPPhase.find_by_title('Continuous Improvement').remaining }
      @qa_remaining                      = default_to_zero { SDPPhase.find_by_title('Quality Assurance').remaining }
      @error                             = ""
      @sold                              = @operational_total
      @provisions_initial                = 0
      @provisions_remaining_should_be    = 0
      @provisions_remaining              = 0 # Project management provision + operational provisions  (10% of 2011)
      @provisions_diff                   = 0
      @risks_remaining                   = 0
      @risks_remaining_should_be         = 0
      provision_qa_ci                    = 0
      @provisions.each { |p|
        calculate_provision(p,@operational_total_2011, @operational_total_2012, @operational_percent_total)
        @sold += p.initial_should_be if p.title != 'Operational Management' # as already counted in @operational_total
        if p.title == 'Operational Management' or p.title == 'Project Management'
          @provisions_initial             += p.initial
          @provisions_remaining_should_be += p.reevaluated_should_be
          @provisions_remaining           += p.reevaluated
          @provisions_diff                += p.difference
        elsif p.title == 'Continuous Improvement' or p.title == 'Quality Assurance'
          provision_qa_ci += p.reevaluated_should_be
        elsif p.title == 'Risks'
          @risks_remaining            = p.reevaluated
          @risks_remaining_should_be  = p.reevaluated_should_be
        end
        }
      @real_balance                 = @sdp_initial_balance - (@theorical_management - @remaining_management)
      @real_balance_and_provisions  = @real_balance + @provisions_remaining_should_be
      @not_included_remaining       = (@theorical_management-@remaining_management) + provision_qa_ci
      @other_provisions             = provision_qa_ci + @risks_remaining_should_be
      @total_provisions             = @other_provisions + @provisions_remaining_should_be
      sdp_graph
    rescue Exception => e
      render(:text=>"<b>Error:</b> <i>#{e.message}</i><br/>#{e.backtrace.split("\n").join("<br/>")}")
    end
  end


  def get_sdp_graph_series(method)
    serie   = []
    labels  = []
    logs = SdpImportLog.find(:all, :order=>"id")
    first = logs.first.created_at
    for l in logs
      serie << [l.created_at-first, l.send(method)]
      labels << l.created_at.to_date
    end
    min = serie.map{|p| p[1]}.min
    max = serie.map{|p| p[1]}.max
    serie = serie.map{ |l| [l[0], l[1]]}
    [serie, min, max, labels]
  end  

  def sdp_graph
    chart = GoogleChart::LineChart.new('600x200', "Gain", true)
    serie1, min1, max1, labels1 = get_sdp_graph_series(:sdp_real_balance_and_provisions)
    serie2, min2, max2, labels2 = get_sdp_graph_series(:sdp_initial_balance)
    #serie3, min3, max3, labels3 = get_sdp_graph_series(:sdp_real_balance)
    serie4, min4, max4, labels4 = get_sdp_graph_series(:provisions)
    min = [min1,min2,min4].min
    max = [max1,max2,min4].max
    serie1 = serie1.map{ |l| [l[0], l[1]-min]}
    serie2 = serie2.map{ |l| [l[0], l[1]-min]}
    #serie3 = serie3.map{ |l| [l[0], l[1]-min]}
    serie4 = serie4.map{ |l| [l[0], l[1]-min]}
    chart.data "Total gain",        serie1, '0000ff'
    chart.data "SDP balance",       serie2, 'AA0000'
    #chart.data "SDP real balance",  serie3, 'ff0000'
    chart.data "Provisions",        serie4, '00ff00'
    chart.axis :y, :range => [min,max], :font_size => 10, :alignment => :center
    #chart.axis :x, :labels => labels1, :font_size => 10, :alignment => :center
    #chart.shape_marker :circle, :color=>'3333ff', :data_set_index=>0, :data_point_index=>-1, :pixel_size=>7
    @sdp_graph = chart.to_url#({:chd=>"t:#{serie.join(',')}", :chds=>"#{min},#{max}"})    
  end

  def default_to_zero(&block)
    begin
      yield block
    rescue
      return 0
    end
  end

  def history_comparison
    logs = SdpImportLog.find(:all, :limit=>2, :order=>"id desc")
    return if logs.size < 2
    now  = logs[0]
    last = logs[1]
    @sdp_initial_balance_diff         = now.sdp_initial_balance - last.sdp_initial_balance
    @real_balance_and_provisions_diff = now.sdp_real_balance_and_provisions - last.sdp_real_balance_and_provisions
    @theorical_diff                   = (now.sdp_real_balance - now.sdp_initial_balance) - (last.sdp_real_balance - last.sdp_initial_balance)
    @provisions_diff                  = now.provisions - last.provisions
    @remaining_time_diff              = now.remaining_time - last.remaining_time
    @operational_diff                 = now.operational_total_minus_om - last.operational_total_minus_om
    @not_included_remaining_diff      = now.not_included_remaining - last.not_included_remaining
    @sold_diff                        = now.sold - last.sold
  end

  def sdp_index
    sdp_index_prepare
    history_comparison
  end
  
  def sdp_index_by_type_prepare
    return if SDPTask.count.zero?
    begin
      @phases = SDPPhaseByType.find(:all)
      @phases.each { |p|  p.gain_percent = (p.initial==0) ? 0 : (p.balancei/p.initial*100/0.1).round * 0.1 }
      @allPhaseRequestTypes = SDPPhaseByType.all(:select => "DISTINCT(request_type)") # Get all types availables in SDPPhaseByType table
      
      tasks2010                          = SDPTask.find(:all, :conditions=>"iteration='2010'")
      tasks2011                          = SDPTask.find(:all, :conditions=>"iteration='2011'")
      op2010                             = tasks2010.inject(0) { |sum, t| t.initial+sum}
      op2011                             = tasks2011.inject(0) { |sum, t| t.initial+sum}
      @operational2011_10percent         = round_to_hour(op2011*0.11111111111)
      @operational_total                 = op2010 + op2011 + @operational2011_10percent
    rescue Exception => e
      render(:text=>"<b>Error:</b> <i>#{e.message}</i><br/>#{e.backtrace.split("\n").join("<br/>")}")
    end
  end
  
  def sdp_index_by_type
    sdp_index_by_type_prepare
  end

  def sdp_yes_check
    @task_ids = SDPTask.find(:all, :conditions=>"initial > 0").collect{ |t| "'#{t.request_id}'" }.uniq
    @yes_but_no_task_requests = Request.find(:all, :conditions=>"sdp='yes' and  sdpiteration!='2011' and sdpiteration!='2010' and request_id not in (#{@task_ids.join(',')})")
    @yes_but_cancelled_requests = Request.find(:all, :conditions=>"sdpiteration!='2011' and sdpiteration!='2010' and request_id in (#{@task_ids.join(',')}) and (status='cancelled' or status='removed')")
    @no_but_sdp = Request.find(:all, :conditions=>"request_id in (#{@task_ids.join(',')}) and sdp='no'")
  end

  def requests_ended_check
    reqs = Request.find(:all, :conditions=>"resolution='ended' or resolution='aborted'")
    @tasks = []
    reqs.each { |r|
      @tasks += SDPTask.find(:all, :conditions=>"request_id='#{r.request_id}' and remaining > 0")
      }
    ids = @tasks.collect {|t| t.request_id}.uniq.join(',')
    if ids == ""
      @requests = []
    else
      @requests = Request.find(:all, :conditions=>"request_id in (#{ids})")
    end
    @no_end_date = Request.find(:all, :conditions=>"(resolution='ended' or resolution='aborted') and end_date=''")
  end

  def requests_should_be_ended_check
    reqs = Request.find(:all, :conditions=>"status='assigned' and resolution!='ended' and resolution!='aborted'")
    @tasks = []
    reqs.each { |r|
      tmp = SDPTask.find(:all, :conditions=>"request_id='#{r.request_id}'")
      remaining = tmp.inject(0.0)  { |sum, t| sum+t.remaining}
      @tasks += tmp if remaining == 0
      }
    ids = @tasks.collect {|t| t.request_id}.uniq.join(',')
    if ids == ""
      @requests = []
    else
      @requests = Request.find(:all, :conditions=>"request_id in (#{ids})", :order=>"assigned_to")
    end
  end

  def workload_check
    @requests = Request.all
    @tasks = []
    @requests.each { |r|
      @tasks += SDPTask.find(:all, :conditions=>"request_id='#{r.request_id}' and remaining > 0")
      }
  end

  def sdp_people
    tasks   = SDPTask.find(:all, :conditions=>"iteration!='HO' and iteration!='P'")
    @trig   = tasks.collect { |t| t.collab }.uniq
    @people = []
    @trig.each { |trig|
      tasks   = SDPTask.find(:all, :conditions=>"collab='#{trig}' and iteration!='HO' and iteration!='P'")
      initial = tasks.inject(0.0) { |sum, t| sum+t.assigned}
      balance = tasks.inject(0.0) { |sum, t| sum+t.balancea}
      if initial > 0
        percent   = ((balance / initial)*100 / 0.1).round * 0.1
        @people << [trig,initial, balance, percent]
      else
        @people << [trig,initial, balance, 0]
      end
      }
    @people = @people.sort_by { |p| [-p[3],-p[1]]}
  end

  def sdp_logs
    @people = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0", :order=>"name")
    @last_sdp_phase = SDPPhase.find(:first, :order=>'updated_at desc')
    if @last_sdp_phase != nil
      @last_sdp_update = @last_sdp_phase.updated_at
    else
      @last_sdp_update = nil
    end
  end

  def sdp_conso
    @people = Person.find(:all, :conditions=>"is_supervisor=0").select {|p| p.sdp_logs.last}.sort_by { |p| p.sdp_logs.last.percent }
    @init_total     = @people.map{|p| p.sdp_logs.last.initial}.inject(0) { |i, sum| sum+i}
    @balance        = @people.map{|p| p.sdp_logs.last.balance}.inject(0) { |i, sum| sum+i}
    @percent_total  = ((@balance / @init_total)*100 / 0.01).round * 0.01
  end

  def sdp_add
    @requests = Request.find(:all, :conditions=>"sdp='No' and resolution='in progress' and status!='to be validated' and complexity!='TBD' and status!='cancelled'")
    @pbs      = Request.find(:all, :conditions=>"sdp='No' and resolution='in progress' and (status='to be validated' or status='cancelled' or status='removed')")
  end

  def load_errors
    # check if sdp loads are corrects
    @empty_sdp_iteration = Request.find(:all, :conditions=>"sdpiteration='' and status!='removed'", :order=>"request_id")
    # TODO: not portable
    @checks = Request.find(:all, :conditions=>"status!='removed' and sdp='Yes' and sdpiteration!='' and sdpiteration!='2011' and sdpiteration!='2010'", :order=>"request_id")
    @checks = @checks.select {|r|
      r.workload2.to_f != r.sdp_tasks_initial_sum
      }
  end

  def import_monthly_tasks_form
    @ope = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0 and is_transverse=0", :order=>"name")
    @service_resp = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0", :order=>"name").select{ |p| p.has_role?('ServiceLineResp')}
    @cpdp_people = Person.find(:all, :conditions=>"has_left=0 and is_cpdp=1", :order=>"name")
  end

  def import_monthly_tasks
    # operational people
    ope_ids  = params["qr"]["ids"].join(",")
    @oname   = params["qr_name"]
    @oload   = params["qr_load"]
    @ope     = Person.find(:all, :conditions=>"id in (#{ope_ids})", :order=>"name")
    # line responsible people
    resp_ids = params["resp"]
    if not resp_ids; resp_ids = "0"; else; resp_ids = resp_ids["ids"].join(","); end
    @rname = params["resp_name"]
    @rload = params["resp_load"]
    @resp  = Person.find(:all, :conditions=>"id in (#{resp_ids})", :order=>"name")
    # cp/dp people
    cpdp_ids = params["cpdp"]
    if not cpdp_ids; cpdp_ids = "0"; else; cpdp_ids = cpdp_ids["ids"].join(","); end
    @cpdpName = params["cpdp_name"]
    @cpdpLoad = params["cpdp_load"]
    @cpdp = Person.find(:all, :conditions=>"id in(#{cpdp_ids})", :order=>"name")
    render(:layout=>false)
  end

  def requests_by_year
    @requests = Request.find(:all, :conditions=>"status='to be validated'", :order=>"workstream, summary, milestone")
    @years = [2011, 2012, 2013]
  end

  def projects_length
    @projects = Project.find(:all).select { |p| p.projects.size==0}
    @results  = []
    for p in @projects
      m,l,pl = p.length
      if m[0]==m[1]
        mt = -1
      else
        mt = m.join('-')
      end
      if pl <= 0
        percent = 0.0
      else
        percent = (((l-pl).to_f / pl )*100).round
      end
      @results << [p.full_name, mt, l, pl, percent, p.id]
    end
    @results = @results.sort_by { |p| [-p[4], -p[3]]}
  end

  def rmt_date_check
    wp = "'WP1.1 - Quality Control', 'WP1.2 - Quality Assurance'"
    @requests = Request.find(:all, :conditions=>"status!='cancelled' and status!='removed' and resolution='ended' and work_package in (#{wp})")
  end

  def qr_per_ws
    @ws = Workstream.all
    @qr = Person.find(:all, :conditions=>"has_left=0 and is_transverse=0")
    @associations = Hash.new
    @ws.each { |ws|
      @qr.each { |qr|
        projects = qr.active_projects_by_workstream(ws.name)
        if projects.size > 0
          @associations[ws.name] ||= Hash.new
          @associations[ws.name][:ws_projects] ||= Project.active_projects_by_workstream(ws.name).size
          @associations[ws.name][:qr] ||= Array.new
          @associations[ws.name][:qr] << {:name=>qr.name, :projects=>projects}
          @associations[ws.name][:ws_id] = ws.id
        end
        next
        }
      }
  end

  def qr_per_ws_detail
    ws_id = params['id'].to_i
    @ws = Workstream.find(ws_id)
    @qr = Person.find(:all, :conditions=>"has_left=0 and is_transverse=0")
    @associations = Array.new
    @qr.each { |qr|
      projects = qr.active_projects_by_workstream(@ws.name)
      if projects.size > 0
        @associations << {:qr=>qr, :projects=>projects}
      end
      }
  end

  def last_projects
    filter = params[:filter]
    session["last_projects_filter"] = filter
    case filter
    when "m5"
      @projects = Project.find(:all, :order=>"created_at desc").select{|p| 
        m3 = p.find_milestone_by_name("M3")
        m5 = p.find_milestone_by_name("M5") || p.find_milestone_by_name("M5/M7")
        m5 and m5.done == 0 and (m5.active_requests.size > 0 or (m3 and m3.active_requests.size>0))
        }
    else
      @projects = Project.find(:all, :limit=>50, :order=>"created_at desc").select{|p| p.open_requests.size > 0}
    end
  end

  def next_milestones
    @next_milestones = (Milestone.find(:all) + Request.all).select{|m| m.date and m.date >= Date.today()-2.days and m.date <= Date.today()+2.months}.sort_by{|m| m.date ? m.date : Date.today()}
  end

  def project_list
    # verify session filter
    # TODO

    @projects = Project.find(:all).select{ |p| p.has_requests }.sort_by { |p|
      u = p.get_status.updated_at
      if !u
        Time.parse("2000/01/01")
      else
        u
      end
      }.reverse
  end
  
  def check_sdp_remaining_workload
    @sdp_wrong_tasks = []
    sdp_tasks = SDPTask.all
    sdp_tasks.each_with_index do |sdp_task, index|
      rem_coef = sdp_task.remaining.modulo(0.125)
      if sdp_task.remaining > 0 and rem_coef > 0
          @sdp_wrong_tasks << sdp_task
      end
    end
  end
  
  def check_difference_po_milestone_date
    @invalid_requests = []
    Request.find(:all, :conditions=>"status='to be validated'").each do |request|
      @invalid_requests << request if !request.date or request.date.year.to_s != request.po.strip
    end
    @invalid_requests = @invalid_requests.sort_by { |r| [r.workstream, r.summary, (r.date ? r.date.to_s : ""), r.po] }
  end

  def export_database_index
  end
  
  def export_database
    dataPath = Rails.public_path + "/data"
    db_config = ActiveRecord::Base.configurations[RAILS_ENV]
    system("mysqldump -u#{db_config['username']} -p#{db_config['password']} -P 8889 -h localhost #{db_config['database']} > #{dataPath}/dump_bdd.sql")
    system("cd #{dataPath} && tar -zcvf #{dataPath}/dump_bdd.tar.gz dump_bdd.sql")
    send_file "#{dataPath}/dump_bdd.tar.gz"
  end
  
  def create_dump_database
     dataPath = Rails.public_path + "/data"
     db_config = ActiveRecord::Base.configurations[RAILS_ENV]
     system("mysqldump -u#{db_config['username']} -p#{db_config['password']} -P 8889 -h localhost #{db_config['database']} > #{dataPath}/dump_bdd.sql")
     system("cd #{dataPath} && tar -zcvf #{dataPath}/dump_bdd.tar.gz dump_bdd.sql")
     render :nothing => true
  end
  
  def download_dump_database
    scriptPath = RAILS_ROOT+"/script"
    dataPath = Rails.public_path + "/data"
    system('echo "rm #{dataPath}/dump_bdd.sql" | at now +3minute')
    system('echo "rm #{dataPath}/dump_bdd.tar.gz" | at now +3minute')
    send_file "#{dataPath}/dump_bdd.tar.gz"
  end
  
  def delete_bdd_dump_files
    dataPath = Rails.public_path + "/data"
    system("rm -f -r #{dataPath}/dump_bdd.sql && rm -f -r #{dataPath}/dump_bdd.tar.gz")
    render :nothing => true
  end
  
private

  def round_to_hour(f)
    (f/0.125).round * 0.125
  end

  def calculate_provision(p, total2011, total2012, operational_percent)
    factor = 1.25 # 20% of PM (reciprocal)
    case p.title
      when 'Project Management'
        p.difference = round_to_hour(total2011*factor*0.09) + round_to_hour(total2012*factor*0.12) - p.initial + PM_PROVISION_ADJUSTMENT
      when 'Risks'
        p.difference = round_to_hour(total2011*factor*0.04) + round_to_hour(total2012*factor*0.02) - p.initial + RK_PROVISION_ADJUSTMENT
      when 'Operational Management'
        p.difference = operational_percent - p.initial      + OP_PROVISION_ADJUSTMENT
      when '(OLD) Quality Assurance'
        p.difference = 0
      when 'Quality Assurance'
        p.difference = round_to_hour(total2011*factor*0.02) + round_to_hour(total2012*factor*0.01) - p.initial+ QA_PROVISION_ADJUSTMENT
      when 'Continuous Improvement'
        p.difference = round_to_hour((total2011+total2012)*factor*0.05) - p.initial  + CI_PROVISION_ADJUSTMENT
      else
        p.difference = 0
    end
    p.initial_should_be     = p.initial     + p.difference
    p.reevaluated_should_be = p.reevaluated + p.difference
  end

end
