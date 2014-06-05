# import SDP
# input: make a SDP export to Excel and save it as *.csv
#Identifiant,Phase/Activité/Tâche,Charge,,,Cons.,Reste à Faire,Charge révisée,Charge acquise,Itération,Collab,Solde,,
#,,estimée,Ré-évaluée,Attribuée,,,,,,,Initial,Ré-évalué,Attribué

require 'csv'

class Mock
  def id
    0
  end
end

class SDP

	def initialize(path)
    @path = path
	end

  def import(conf='simple', options={})
    @reader = CSV.open(@path, 'r')
    @conf = conf
    @options = options

    begin    
      # skip 2 first lines
      header = @reader.shift
      @reader.shift
      if header.count <= 1
        raise "CSV file not correctly formated"
      end
      if(!options[:project])
        ActiveRecord::Base.connection.execute("TRUNCATE sdp_phases")
        ActiveRecord::Base.connection.execute("TRUNCATE sdp_activities")
        ActiveRecord::Base.connection.execute("TRUNCATE sdp_tasks")
      else
        SDPTask.delete_all("project_code='#{options[:project]}'")
        @current_phase = @current_activity = Mock.new
        # TODO: what to do about phases and activities ?
      end
      @state = :init
      while true
        if @next_row == nil
          @row = @reader.shift
        else
          @row = @next_row
          @next_row = nil
        end
        break if @row.empty?
        insert
        break if @state == :end
      end
      SDPTask.format_stats_by_type()
    rescue Exception => e
      if e.to_s == "CSV::IllegalFormatError"
        raise "Unexpected file format"
      else
        raise "#{e} => #{e.backtrace[0]}"
      end
    end

  end

private

  def sanitize(name)
    return nil if not name
    name.gsub!(160.chr,"")
    name.gsub!(130.chr, "e") # eacute
    name.gsub!(133.chr, "a") # a grave
    name.gsub!(135.chr, "c") # c cedille
    name.gsub!(138.chr, "e") # e grave
    name.gsub!(140.chr, "i") # i flex
    name.gsub!(147.chr, "o") # o flex
    name.gsub!(156.chr, "oe") # oe
    name.gsub!(167.chr, "o") # °    
    name.strip
  end

  def populate(p)
    p.initial     = @row[TASK_IMPORT_CONFIG[@conf]['initial']]
    p.reevaluated = @row[TASK_IMPORT_CONFIG[@conf]['reevaluated']]
    p.assigned    = @row[TASK_IMPORT_CONFIG[@conf]['assigned']]
    p.consumed    = @row[TASK_IMPORT_CONFIG[@conf]['consumed']]
    p.remaining   = @row[TASK_IMPORT_CONFIG[@conf]['remaining']]
    p.revised     = @row[TASK_IMPORT_CONFIG[@conf]['revised']]
    p.gained      = @row[TASK_IMPORT_CONFIG[@conf]['gained']]
    p.iteration   = @row[TASK_IMPORT_CONFIG[@conf]['iteration']]
    p.collab      = @row[TASK_IMPORT_CONFIG[@conf]['collab']]
    p.balancei    = @row[TASK_IMPORT_CONFIG[@conf]['balancei']]
    p.balancer    = @row[TASK_IMPORT_CONFIG[@conf]['balancer']]
    p.balancea    = @row[TASK_IMPORT_CONFIG[@conf]['balancea']]
  end

  def debug
    puts "=================================="
    puts @row[TASK_IMPORT_CONFIG[@conf]['project_code']]
    puts @row[TASK_IMPORT_CONFIG[@conf]['initial']]
    puts @row[TASK_IMPORT_CONFIG[@conf]['reevaluated']]
    puts @row[TASK_IMPORT_CONFIG[@conf]['assigned']]
    puts @row[TASK_IMPORT_CONFIG[@conf]['consumed']]
    puts @row[TASK_IMPORT_CONFIG[@conf]['remaining']]
    puts @row[TASK_IMPORT_CONFIG[@conf]['revised']]
    puts @row[TASK_IMPORT_CONFIG[@conf]['gained']]
    puts @row[TASK_IMPORT_CONFIG[@conf]['iteration']]
    puts @row[TASK_IMPORT_CONFIG[@conf]['collab']]
    puts @row[TASK_IMPORT_CONFIG[@conf]['balancei']]
    puts @row[TASK_IMPORT_CONFIG[@conf]['balancer']]
    puts @row[TASK_IMPORT_CONFIG[@conf]['balancea']]
    puts "=================================="
  end

  def create_phase
    t = sanitize(@row[TASK_IMPORT_CONFIG[@conf]['title']])
    return if t == nil
    #p = SDPPhase.find_by_title(t)
    p = SDPPhase.new # if not p
    p.title = t
    populate(p)
    p.save
    @current_phase = p
  end

  def create_activity
    t = sanitize(@row[TASK_IMPORT_CONFIG[@conf]['title']])
    return if t == nil
    #p = SDPActivity.find_by_title_and_phase_id(t,@current_phase.id)
    p = SDPActivity.new # if not p
    p.phase_id = @current_phase.id
    p.title = t
    populate(p)
    p.save
    @current_activity = p
  end

  def create_task
    t = sanitize(@row[TASK_IMPORT_CONFIG[@conf]['title']])
    return if t == nil
    #p = SDPTask.find_by_sdp_id(@row[ID])
    #debug
    #exit
    p             = SDPTask.new # if not p
    p.phase_id    = @current_phase.id
    p.activity_id = @current_activity.id
    p.sdp_id      = @row[TASK_IMPORT_CONFIG[@conf]['id']]
    p.title       = t
    p.project_code= @options[:project] || @row[TASK_IMPORT_CONFIG[@conf]['project_code']]
    r_id          = /^\[(\d+)\].*$/.match(t)
    p.request_id  = r_id[1] if r_id
    populate(p)
    p.save
  end

  def insert
    #puts @row.join(', ')
    #puts @row[ID]
    if @row[TASK_IMPORT_CONFIG[@conf]['id']]==nil
      case @state
        when :init;  @state = :phase
        when :phase; @state = :activity
        when :task
          @next_row = @reader.shift
          if @next_row[TASK_IMPORT_CONFIG[@conf]['id']] == nil
            @state = :phase
          else
            @state = :activity
          end
        when :total
          @state = :end
        else; raise "state error #{@state.to_s}"
      end
    elsif @row[TASK_IMPORT_CONFIG[@conf]['id']]=="Total"
      @state = :total
    else
      @state = :task
    end
    case @state
      when :phase
        create_phase if !@options[:project]
      when :activity
        create_activity if !@options[:project]
      when :task
        create_task
      when :total
        @state = :end
      else; raise "state error #{@state.to_s}"
    end
  end
  
end

#=begin
#i = Sdp.new('C:\Users\faivremacon\My Documents\Downloads\SDP.csv')
#i.import
#=end

