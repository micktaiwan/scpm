# generate a html report based on the Mantis csv report
require 'csv'

class CvsCi

  attr_accessor  :internal_id,
:external_id,
:stage,
:category,
:severity,
:summary,
:description,
:status,
:submission_date,
:reporter,
:last_update,
:last_update_person,
:assigned_to,
:priority,
:visibility,
:resolution_charge,
:additional_information,
:taking_into_account_date,
:realisaton_date,
:realisation_author,
:delivery_date,
:origin,
:improvement_target_objective,
:scope_l2,
:deliverable_list,
:accountable,
:deployment,
:launching_date,
:validation_date_objective,
:airbus_validation_date_objective,
:deployment_date_objective,
:sali_validation_date,
:airbus_validation_date,
:deployment_date,
:deployment_date_review

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
end

class CvsCiReport

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
      #puts "#{attr_name} = '#{row[index]}'"
      eval("r.#{attr_name} = '#{row[index]}'") # r.id = row[1]
      }
    @requests << r
  end

  def sanitize_attr(name)
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
