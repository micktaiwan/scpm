# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  include Authentication

  def my_simple_format(text)
    text.split("\n").join("<br/>") + "<br/>"
  end
  
end
