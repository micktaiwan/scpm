module WelcomeHelper


  def sanitize(name)
    name = name.downcase
    name.gsub!("/","")
    name.gsub!("  ","_")
    name.gsub!(" ","_")
    name.gsub!("-","_")
    name
  end

  def report_by(title, rs, id)
    rv  = "<a href='#' onclick=\"$('#{id}_#{title}').toggle();return false;\">"
    rv += ((title=="" ? "(empty)":title) + "</a>: " + rs.size.to_s + "<br/>")
    rv += "<ul id='"+id+"_"+title+"' style='display:none'>"
    rs.each { |r|
      rv += ("<li class='#{sanitize(r.status)}'>" + r.workstream + ": <a href='http://toulouse.sqli.com/EMN/view.php?id=#{r.id}'>" + r.summary + "</a> " + r.work_package  + " <b>" +  r.status + "</b> " + r.assigned_to + "</li>")
      }
    rv += "</ul>"
  end      

end
