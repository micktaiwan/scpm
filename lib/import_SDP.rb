# import SDP

require "ExcelFile"

class SDPLine

  def initialize
  
  end

end

class ImportSDP

	def initialize
		@excel = ExcelFile.new
	end
	
	def open(path)
    @excel.open(path)
  end	

  def close
    @excel.close
  end
  
  def list
    @list = []
    puts @excel.cells(3,5).text
#    { |txt, line, col|
#      txt, nb = parse(txt)
#      puts "#{nb}: #{txt}" if nb
#      }
    puts @list.size  
    @list
  end
  
  def parse(txt)
    s   = txt.scan(/\[(\d+)\]/)
    nb  = (s==[]) ? nil : s[0][0].to_i
    @list << nb if nb and not @list.include?(nb)
    return [txt,nb]
  end

end

#=begin
i = ImportSDP.new
i.open('C:\Users\faivremacon\My Documents\Downloads\Rapport (4).xls')
i.list
i.close
#=end
