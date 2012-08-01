# generate a html report based on the Mantis csv report
require 'csv'

class CvsRequest

  attr_accessor :workstream, :status, :assigned_to, :resolution,
    :updated, :reporter, :id, :view_status, :milestone, :priority,
    :summary, :date_submitted, :product_version,
    :severity, :platform, :work_package, :complexity, :contre_visite,
    :start_date, :sdp, :pm, :milestone_date, :project_name, :sdpiteration,
    :end_date, :milestone_date, :actual_m_date, :po,
    :status_to_be_validated, :status_new, :status_feedback, :status_acknowledged, :status_assigned, :status_contre_visite, :status_performed, :status_cancelled, :status_closed,
    :total_csv_severity, :total_csv_category, :contre_visite_milestone, :request_type

  def initialize
  end

  def method_missing(m, *args, &block)
    #raise "CvsRequest does not have a '#{m}' attribute/method"
  end

  def to_hash
    h = Hash.new
    self.instance_variables.each { |var|
      h[var[1..-1].to_sym] = self.instance_variable_get(var)
      }
    h
  end
  
  # EISQ Override
  def is_physical=(isPhysicalParameter)
    #puts "request_type = '#{isPhysicalParameter}'"
    @request_type = isPhysicalParameter
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
      values = @requests.collect { |r| eval("r.#{key}")}.map{|i| i.downcase}.uniq.sort
      for value in values
        yield value, @requests.select { |r| eval("r.#{key}.downcase == '#{value}'")}.sort_by { |r| [r.start_date, r.workstream]}
      end
      return
    end
    raise "Report does not have a '#{m}' attribute/method"
  end

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
      #puts "#{attr_name} ----> '#{row[index]}'"
      eval("r.#{attr_name} = '#{row[index]}'") # r.id = row[1]
      }
    @requests << r
  end

  def sanitize_attr(name)
    raise "no name for attribute (importing requests). Check if you really importing a request export file." if !name
    name = name.downcase
    name.gsub!(" #","")
    name.gsub!("/","")
    name.gsub!("  ","_")
    name.gsub!(" ","_")
    name.gsub!("-","_")
    name.gsub!(".","")
    name
  end

end

=begin
r = Report.new('/home/mick/DL/mfaivremacon.csv')
r.parse
r.generate_html_file('/home/mick/DL/test.html')
=end
