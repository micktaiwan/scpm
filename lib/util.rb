class Object
  ##
  #   @person ? @person.name : nil
  # vs
  #   @person.try(:name)
  def try(method)
    send method if respond_to? method
  end
end

module Util

  # wdays is an array with the days of the week
  # to exclude days (eg: wdays = [0,6] for sunday and saturday )
  # return [diff between 2 dates, nb of holidays]
  # direction:
  # - right: every holidays add more days to the right limit when counting holidays
  # - left: holiday is just the nb of holidays inside the date interval
  def self.calculate_diff_and_holidays(d1,d2, direction=:right, wdays=[0,6])
    diff     = (d2 - d1)
    holidays = 0
    ret      = (d2-d1).divmod(7)
    holidays = ret[0].truncate * wdays.length
    d1       = d2 - ret[1]
    while(d1 < d2+((direction==:right) ? holidays : 0))
      holidays += 1 if wdays.include?(d1.wday)
      d1 += 1
    end
    [diff, holidays]
  end

  # add holidays to end_date
  # start_date must be a working day !
  def self.real_end_date(start_date,initial_duration)
    diff, holidays = calculate_diff_and_holidays(start_date, start_date+initial_duration.days)
    # end_date is start_date + duration + nb of holiday
    # but if holiday is odd, it means it lacks sunday as we assume start day is not a holiday already,
    # thus the modulo 2
    end_date = start_date + diff.days + (holidays+holidays % 2).days
    end_date = end_date - 2.days if end_date.wday == 1 # monday
    end_date
  end

end
