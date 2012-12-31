require 'csv'

class CsvCi

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
    :launching_date_ddmmyyyy,
    :sqli_validation_date_objective,
    :airbus_validation_date_objective,
    :sqli_validation_date_review,
    :airbus_validation_date_review,
    :deployment_date_objective,
    :sqli_validation_date,
    :airbus_validation_date,
    :deployment_date,
    :deployment_date_review,
    :airbus_responsible,
    :kick_off_date

  def initialize
  end

  def method_missing(m, *args, &block)
    #raise "CsvCi does not have a '#{m}' attribute/method"
  end

  def to_hash
    h = Hash.new
    self.instance_variables.each { |var|
      h[var[1..-1].to_sym] = self.instance_variable_get(var)
      }
    h
  end
end

class CsvCiReport

  attr_reader :projects

  def initialize(path)
    @path     = path
    @projects = []
    @columns  = Hash.new
  end

  def parse
    reader = CSV.open(@path, 'r')
    get_columns(reader.shift)
    while not (row = reader.shift).empty?
      parse_row(row)
    end
  end

private

  def get_columns(row)
    row.each_with_index { |r,i|
      @columns[sanitize_attr(r)] = i
      #puts sanitize_attr(r)
      #exit
      }
  end

  def parse_row(row)
    r = CsvCi.new
    @columns.each { |attr_name, index|
      #puts "#{attr_name} = '#{row[index]}'"
      begin
        eval("r.#{attr_name} = \"#{sanitize_value(row[index])}\"")  # r.id = row[1]
      rescue Exception => e
        raise "Error: #{e} attr_name=#{attr_name}, value=#{sanitize_value(row[index])}"
      end
      }
    @projects << r
  end

  def sanitize_value(value)
    return nil if !value
    value.gsub!("\"","'")
    if value =~ /(\d\d)\/(\d\d)\/(\d\d\d\d)/
      value = "#{$2}/#{$1}/#{$3}"
    end
    value
  end

  def sanitize_attr(name)
    name = name.downcase
    name.gsub!(" #","")
    name.gsub!("/","")
    name.gsub!("  ","_")
    name.gsub!("(","")
    name.gsub!(")","")
    name.gsub!(" ","_")
    name.gsub!("-","_")
    name.gsub!(".","")
    name.gsub!(/\d\d\_/,"")
    #name.gsub!(/\_\d\d/ ,"")
    name = "internal_id" if name == "internal"
    name = "external_id" if name == "id"
    name
  end

end
