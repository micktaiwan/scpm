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
    rv += "<table><tr class='theader'><td>#</td><td>WS</td><td>Project</td><td>Type</td><td>Status</td><td>Resp</td><td>Start date</td><td>Progress</td><td>SDP</td></tr>"
    rs.each { |r|
      rv += ("<tr class='#{sanitize(r.status)}'><td>" + r.request_id.to_i.to_s + "</td><td>" + r.workstream + "</td><td><a href='http://toulouse.sqli.com/EMN/view.php?id=#{r.request_id.to_i}'>" + r.summary + "</a></td><td>" + r.work_package  + "</td><td><b>" +  r.status + "</b></td><td>" + r.assigned_to + "</td><td>" + r.start_date.to_s + "</td><td>" + r.resolution + "<td>")
      rv += "<b>" if r.sdp == "No"
      rv += " SDP:" + r.sdp if r.sdp
      rv += "</b>" if r.sdp == "No"
      rv += "</td></tr>"
      }
    rv += "</table>"
    rv += "</ul>"
  end      

end
