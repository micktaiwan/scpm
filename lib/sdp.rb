# import SDP
# make a SDP export to Excel, delete the 2 first lines and save it as *.csv
#Identifiant,Phase/Activité/Tâche,Charge,,,Cons.,Reste à Faire,Charge révisée,Charge acquise,Itération,Collab,Solde,,
#,,estimée,Ré-évaluée,Attribuée,,,,,,,Initial,Ré-évalué,Attribué

require 'csv'

class SDP

  ID          = 0
  TITLE       = 1
  INTIAL      = 2
  REEVALUATED = 3
  ASSIGNED    = 4
  CONSUMED    = 5
  REMAINING   = 6
  REVISED     = 7
  GAINED      = 8
  ITERATION   = 9
  COLLAB      = 10
  BALANCEI    = 11
  BALANCER    = 12
  BALANCEA    = 13

	def initialize(path)
    @path = path
	end

  def import
    @reader = CSV.open(@path, 'r')
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
    end
  end

private

  def sanitize(name)
    return nil if not name
    name.gsub!(160.chr,"")
    name
  end

  def populate(p)
    p.initial     = @row[INTIAL]
    p.reevaluated = @row[REEVALUATED]
    p.assigned    = @row[ASSIGNED]
    p.consumed    = @row[CONSUMED]
    p.remaining   = @row[REMAINING]
    p.revised     = @row[REVISED]
    p.gained      = @row[GAINED]
    p.iteration   = @row[ITERATION]
    p.collab      = @row[COLLAB]
    p.balancei    = @row[BALANCEI]
    p.balancer    = @row[BALANCER]
    p.balancea    = @row[BALANCEA]
  end

  def create_phase
    t = sanitize(@row[TITLE])
    return if t == nil
    p = SDPPhase.find_by_title(t)
    p = SDPPhase.new if not p
    p.title = t
    populate(p)
    p.save
    @current_phase = p
  end

  def create_activity
    t = sanitize(@row[TITLE])
    return if t == nil
    p = SDPActivity.find_by_title_and_phase_id(t,@current_phase.id)
    p = SDPActivity.new if not p
    p.phase_id = @current_phase.id
    p.title = t
    populate(p)
    p.save
    @current_activity = p
  end

  def create_task
    t = sanitize(@row[TITLE])
    return if t == nil
    p = SDPTask.find_by_sdp_id(@row[ID])
    p = SDPTask.new if not p
    p.phase_id    = @current_phase.id
    p.activity_id = @current_activity.id
    p.sdp_id = @row[ID]
    p.title  = t
    r_id = /^\[(\d+)\].*$/.match(t)
    p.request_id = r_id[1] if r_id
    populate(p)
    p.save
  end

  def insert
    #puts @row.join(', ')
    #puts @row[ID]
    if @row[ID]==nil
      case @state
        when :init;  @state = :phase
        when :phase; @state = :activity
        when :task
          @next_row = @reader.shift
          if @next_row[ID] == nil
            @state = :phase
          else
            @state = :activity
          end
        else; raise "state error"
      end
    elsif @row[ID]=="Total"
      @state = :total
    else
      @state = :task
    end
    case @state
      when :phase
        create_phase
      when :activity
        create_activity
      when :task
        create_task
      when :total
        #puts "END"
      else; raise "state error"
    end
  end

end

#=begin
#i = Sdp.new('C:\Users\faivremacon\My Documents\Downloads\SDP.csv')
#i.import
#=end
