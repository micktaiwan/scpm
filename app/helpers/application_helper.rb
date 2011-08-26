# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  include Authentication

  def my_simple_format(text)
    return "" if not text
    text.split("\n").join("<br/>") + "<br/>"
  end

  def my_time(t)
    t.strftime("%d-%b-%Y %H:%M")
  end

  def menu_style(c,a)
    if c == controller_name and (a == '*' or a == action_name)
      'menu active'
    else
      'menu'
    end
  end

  def cascade_send(object, methods)
    m_arr = methods.split('.')
    rv = object
    m_arr.each { |m|
      rv = rv.send(m)
      }
    return rv
  end

  def get_bandeau
    b = Bandeau.find(:first, :order=>"last_display")
    if b
      b.last_display  = Time.now
      b.nb_displays   = b.nb_displays + 1
      b.save
    end
    b
  end

  def options_with_colors(value, colors)
    colors.collect do |txt, code, color|
      "<option value='#{code}' style='background-color:#{color};' #{value==code ? " selected='selected'":""}>#{txt}</option> "
    end.join
  end

  def wlweek(day)
    (day.year.to_s + filled_number(day.cweek,2)).to_i
  end

  # filled_number(123, 5) => 00123
  def filled_number(n, nb)
    "0"*(nb-n.to_s.size) + n.to_s
  end

  # appended_string("EDY", 5) => "EDY  "
  def appended_string(str, nb, ch=" ")
    str.to_s + ch*(nb-str.to_s.size)
  end

end

class Integer
  def pretty_number
    case
    when self < 1000
      to_s
    when self < 10000
      to_s.insert(1, ",")
    when self < 100000
      ("%.1fk" % (self / 1000.0)).sub(".0", "")
    else
      (self / 1000).pretty_number << "k"
    end
  end
end
