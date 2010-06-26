class Report
  
  attr_accessor :requests

  def initialize(requests)
    @requests = requests
  end
  
  def method_missing(m, *args, &block)  
    if m.to_s[0..2] == "by_"
      key = m.to_s[3..-1] # example: "project"
      couples = [] # to be able to sort by number of requests for a given value
      # get all possible values, example "EA", "EV"
      values = @requests.collect { |r| eval("r.#{key}")}.uniq.sort # compact.sort
      for value in values
        couples << [value, @requests.select { |r| eval("r.#{key} == '#{value}'")}.sort_by { |r| [r.start_date, r.workstream]}]
      end
      # sort by number of requests
      # couples = couples.sort_by { |couple| -couple[1].size}
      
      # now yield values
      for value, rs in couples
        yield value, rs
      end
      return
    end
    raise "Report does not have a '#{m}' attribute/method"
  end

  
end
