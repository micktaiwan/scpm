# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  require File.join(File.dirname(__FILE__), '../../config/constants')
  include Authentication

  def my_simple_format(text)
    return "" if not text
    text.split("\n").join("<br/>") + "<br/>"
  end

  def my_time(t)
    return '' if !t
    t.strftime("%d-%b-%Y %H:%M")
  end

  def my_date(d)
    return '' if !d
    d.strftime('%d-%b-%Y')
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

  def tab_menu(id, arr)
    size = arr.size
    rv = ""
    cookies["tab_menu_"+id] = "0" if !cookies["tab_menu_"+id]
    arr.each_with_index { |title, index|
      rv += "<li "
      if cookies["tab_menu_"+id] == (index+1).to_s
        rv += "id='tabHeaderActive'"
      else
        rv += "id='tabHeader#{index+1}'"
      end
      rv += "><a href='javascript:void(0)' onClick='toggleTab(\"#{id}\", #{index+1},#{size})'><span>#{title}</span></a></li>"
      }
    rv
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
