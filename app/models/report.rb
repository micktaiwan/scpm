class Report
  
  attr_accessor :requests

  def initialize(requests)
    @requests = requests
  end
  
  def method_missing(m, *args, &block)  
    if m.to_s[0..2] == "by_"
      key = m.to_s[3..-1] # example: "project"
      # get all possible values, example "EA", "EV"
      values = @requests.collect { |r| eval("r.#{key}")}.uniq.sort #compact.sort
      for value in values
        yield value, @requests.select { |r| eval("r.#{key} == '#{value}'")}.sort_by { |r| [r.start_date, r.workstream]}
      end
      return  
    end
    raise "Report does not have a '#{m}' attribute/method"
  end

  
end
