require 'win32ole'

class ExcelFile
  attr_reader :excel
  attr_reader :ws
  attr_reader :curx, :cury
  attr_writer :curx, :cury
  
  def initialize
    @curx = 1
    @cury = 1
    @excel = WIN32OLE::new('excel.Application')
  end
  
  def open(path)
    @path = path
    @wb = excel.Workbooks.Open(@path)
    @ws = @wb.Worksheets(1)
  end
  
  def create
    @wb = excel.Workbooks.Add
    @ws = @wb.Worksheets.Add
  end
  
  def close
    @excel.Quit
  end
  
  def saveAs(path)
    @wb.saveas(path)
  end
  
  # return the cell object
  def cells(x,y)
    @ws.cells(x,y)
  end
  
  # yield the value, the line number, the col number + 1
  def each_col(col, max=0, from=1)
    i = from
    while true
      txt = @ws.cells(i,col+1).text
      break if txt == '' or (max>0 and i > max)
      yield txt, i, col+1
      i += 1
    end
  end
  
  def addTitle(title)
    cell = @ws.cells(@cury, 1)
    cell.value = title
    cell.Interior['ColorIndex'] = 36
    range = @ws.range(cell, @ws.cells(@cury,8))
    range.Mergecells = true
    cell.font.name = 'Arial'
    cell.font.size = 14
    range.borders.weight = 2
    @cury += 1
    @curx = 1
  end
  
  def nextLine
    @cury += 1
    @curx = 1
  end
  
  def putText(text)
    cell = @ws.cells(@cury, @curx)
    cell.value = text
    @curx += 1
    cell
  end
  
  def autoFit(x=@curx..@curx)
    x.each {|i|
      @ws.Columns(i).EntireColumn.AutoFit
    } 
  end
  
  def addSheet
    @ws = @wb.Worksheets.Add
    @curx = 1
    @cury = 1
  end
  
  # select a sheet
  def select n
    #puts @wb.Worksheets.ole_methods
    begin
      @ws = @wb.Worksheets.Item n
    rescue
      puts "============== Can not open this sheet (#{n}) ================"
      raise
    end
    @curx = 1
    @cury = 1
  end
  
end
