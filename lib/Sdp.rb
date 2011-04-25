# import SDP
# make a SDP export to Excel, delete the 2 first lines and save it as *.csv
#Identifiant,Phase/Activité/Tâche,Charge,,,Cons.,Reste à Faire,Charge révisée,Charge acquise,Itération,Collab,Solde,,
#,,estimée,Ré-évaluée,Attribuée,,,,,,,Initial,Ré-évalué,Attribué

require 'csv'

class SDP

  ID      = 0
  TITLE    = 1

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

  def create_phase
    t = @row[TITLE]
    return if t == nil
    p = SDPPhase.find_by_title(t)
    p = SDPPhase.new if not p
    p.title = t
    p.save
    @current_phase = p
  end

  def create_activity
    t = @row[TITLE]
    return if t == nil
    p = SDPActivity.find_by_title_and_phase_id(t,@current_phase.id)
    p = SDPActivity.new if not p
    p.phase_id = @current_phase.id
    p.title = t
    p.save
    @current_activity = p
  end
  
  def create_task
    t = @row[TITLE]
    return if t == nil
    p = SDPTask.find_by_sdp_id(@row[ID])
    p = SDPTask.new if not p    
    p.phase_id    = @current_phase.id
    p.activity_id = @current_activity.id
    p.sdp_id = @row[ID]
    p.title  = t
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
        puts "END"
      else; raise "state error"
    end
  end

end

#=begin
#i = Sdp.new('C:\Users\faivremacon\My Documents\Downloads\SDP.csv')
#i.import
#=end
