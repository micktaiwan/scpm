# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  include Authentication

  def my_simple_format(text)
    return "" if not text
    text.split("\n").join("<br/>") + "<br/>"
  end
  
  def my_time(time)
    time.strftime("%d-%b-%Y %H:%m")
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

end

