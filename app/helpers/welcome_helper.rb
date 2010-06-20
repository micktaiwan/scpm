module WelcomeHelper


  def report_by(type, rs)
    rv  = "<a href='#' onclick=\"$('assigned_to_#{type}').toggle();return false;\">"
    rv += (type + ": " + rs.size.to_s + "</a><br/>")
    rv += "<ul id='assigned_to_"+type+"' style='display:none'>"
    rs.each { |r|
      rv += ("<li>" + r.project + ": " + r.summary_project_name + " " + r.work_package  + " " +  r.status + "</li>")
      }
    rv += "</ul>"
  end      

end
