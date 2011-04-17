# import SDP

require "ExcelFile"

class SDPLine
  TASKID = 1
end

class SDPPhase

  def initialize  
  end

end

class SDP

	def initialize
		@excel = ExcelFile.new
    @lines =[]
	end
	
	def open(path)
    @excel.open(path)
  end	

  def close
    @excel.close
  end
  
  def import(path)
    @line = 3
    open(path)
    parse_phase
    close
  end
  
  def parse_phase
    @line = SDPPhase.new.parse(@line)
    parse_activity
  end
  
  def parse_phase
    parse_tasks
  end
  
  
  
    id = @excel.cells(line,TASKID).text
    if id == id.to_i
      l = SDPLine.new
      
      lines << l
    end
    s   = txt.scan(/\[(\d+)\]/)
    nb  = (s==[]) ? nil : s[0][0].to_i
    @list << nb if nb and not @list.include?(nb)
    return [txt,nb]

end

#=begin
i = SDP.new
i.import('C:\Users\faivremacon\My Documents\Downloads\Rapport (9).xls')
#=end
