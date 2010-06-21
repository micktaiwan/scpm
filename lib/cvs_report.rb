# generate a html report based on the Mantis csv report
require 'csv'

class CvsRequest

  attr_accessor :workstream, :status, :assigned_to, :resolution,
    :updated, :reporter,
    :id, :view_status, :milestone, :priority,
    :summary, :date_submitted, :product_version,
    :severity, :platform, :work_package, :complexity,
    :start_date
    
  def initialize
  end

  def method_missing(m, *args, &block)  
    #raise "RRequest does not have a '#{m}' attribute/method"
  end
  
  def to_hash
    h = Hash.new
    self.instance_variables.each { |var|
      h[var[1..-1].to_sym] = self.instance_variable_get(var)
      }
    h  
  end
end

class CvsReport
  
  attr_reader :requests

  def initialize(path)
    @path = path
    @requests = []
    @columns = Hash.new
  end

  def parse
    reader = CSV.open(@path, 'r')
    get_columns(reader.shift)
    while not (row = reader.shift).empty?
      parse_row(row)
    end
  end

  def method_missing(m, *args, &block)  
    if m.to_s[0..2] == "by_"
      key = m.to_s[3..-1] # example: "project"
      # get all possible values, example "EA", "EV"
      values = @requests.collect { |r| eval("r.#{key}")}.uniq.sort
      for value in values
        yield value, @requests.select { |r| eval("r.#{key} == '#{value}'")}.sort_by { |r| [r.start_date, r.workstream]}
      end
      return  
    end
    raise "Report does not have a '#{m}' attribute/method"
  end

=begin
  def generate_html_file(path)
    file = File.open(path, "w")
    file << "<html><head></head><body><h1>EISQ Request Report</h1>"
    generate_stats(file)
    file << "</body></html>"
    file.close
  end  
  
  def generate_stats(file)
    file << "<h2>Overall statistics</h2>"
    file << "<h2>By workstream</h2>"
  end
=end

private

  def get_columns(row)
    row.each_with_index { |r,i|
      @columns[sanitize_attr(r)] = i
      #puts sanitize_attr(r)
      }
  end

  def parse_row(row)
    r = CvsRequest.new
    @columns.each { |attr_name, index|
      #puts "#{attr_name} = '#{row[index]}'"
      eval("r.#{attr_name} = '#{row[index]}'") # r.id = row[1]
      }
    @requests << r
  end
  
  def sanitize_attr(name)
    name = name.downcase
    name.gsub!("/","")
    name.gsub!("  ","_")
    name.gsub!(" ","_")
    name.gsub!("-","_")
    name
  end
    
end

=begin
r = Report.new('/home/mick/DL/mfaivremacon.csv')
r.parse
r.generate_html_file('/home/mick/DL/test.html')
=end

