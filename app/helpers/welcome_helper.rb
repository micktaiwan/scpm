module WelcomeHelper


  def workload(rs)
    rs.inject(0.0) { |sum, r| sum + r.workload}
  end

=begin
  def sanitize(name)
    name = name.downcase
    name.gsub!("/","")
    name.gsub!("  ","_")
    name.gsub!(" ","_")
    name.gsub!("-","_")
    name
  end
=end


  def report_by(title, rs, id, expanded = false)    
    title = "nil" if not title
    if not expanded
      rv  = "<a href='#' onclick=\"$('#{id}_#{title}').toggle();return false;\">"
      rv += ((title=="" ? "(empty)" : title) + "</a>: <b>#{rs.size}</b> (#{workload(rs)})<br/>")
      rv += "<ul id='"+id+"_"+title+"' style='display:none'>"
    else
      rv = ((title=="" ? "(empty)" : title) + ": <b>#{rs.size}</b> (#{workload(rs)})<br/>")
      rv += "<ul id='"+id+"_"+title+"'>"
    end
    
    rv += "<table><tr class='theader'><td>#</td><td>WS</td><td>Project</td><td>PM</td><td>Type</td><td>Miles.</td><td>Status</td><td>Resp</td><td>Load</td><td>Start date</td><td>End date</td><td>Progress</td><td>SDP</td></tr>"
    rs.each { |r|
      rv += ("<tr class='#{r.sanitized_status}'><td>#{r.request_id.to_i}</td><td>#{r.workstream}</td><td><a href='http://toulouse.sqli.com/EMN/view.php?id=#{r.request_id.to_i}'>#{r.summary}</a></td><td>#{r.pm}</td><td>#{r.work_package}</td><td>#{r.milestone}</td><td><b>#{r.status}</b></td><td>#{r.assigned_to}</td><td>#{r.workload}</td><td>#{r.start_date}</td><td>#{r.foreseen_end_date_str}</td><td class='status_#{r.sanitized_resolution}'>#{r.resolution}<td>")
      # TODO: write an helper in the request model
      rv += "<b>" if r.sdp == "No"
      rv += " SDP:" + r.sdp if r.sdp
      rv += "</b>" if r.sdp == "No"
      rv += "</td></tr>"
      }
    rv += "</table>"
    rv += "</ul>"
  end      

end
