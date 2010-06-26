module WelcomeHelper

Wp_index = {
"WP1.1 - Quality Control" => 0,
"WP1.2 - Quality Assurance" => 4,
"WP2 - Quality for Maintenance" => 8,
"WP3 - Modeling" => 9,
"WP4 - Surveillance" => 10,
"WP4.2 - Surveillance Root cause" => 10,
"WP5 - Change Accompaniment" => 11,
"WP6.1 - Coaching PP" => 12,
"WP6.2 - Coaching BRD" => 13
}

Comp_index = {
"Easy" => 0,
"Medium" => 1,
"Difficult" => 2
}

Milestone_index = {
"M1-M3" => 0,
"M3-M5" => 1,
"M5-M10" => 2,
"Post-M10" => 3,
"N/A" => 0,
}

rows, cols = 8, 3
#Loads = Array.new(rows) { Array.new(cols) }
Loads = [
  # WP 1.1
  [4.5,5.25,7.75],
  [3.625,4.25,6],
  [2.875,3.875,6.5],
  [4.5,5.25,7.75],
  # WP 1.2
  [3.375,3.875,4.5],
  [6.125,7.75,10.375],
  [6,6.625,7.75],
  [6,7.75,10.25],
  # WP 2
  [5.75,8.625,13.25],
  # WP 3
  [9.5,18,25],
  # WP 4
  [6.125,8.5,13.5],
  # WP 5
  [11.875,25.75,47.25],
  # WP 6
  [5.25,12.5,23],
  [3.75,11.5,24],
  [2.25,6.5,16],
  [3,15,35],
  [8.75,13.25,18.25],
  # WP 1.1 CV
  [0.5,0.5,0.75],
  [1,1,1.5],
  [0.375,0.375,0.5],
  [2,2.5,3],
  # WP 1.2 CV
  [0.5,0.5,0.5],
  [2,2.5,3],
  [2,3,4],
  [3,4,5]]

  def sanitize(name)
    name = name.downcase
    name.gsub!("/","")
    name.gsub!("  ","_")
    name.gsub!(" ","_")
    name.gsub!("-","_")
    name
  end


  def wp_index(wp)
    rv = Wp_index[wp]
    raise "no workpackage #{wp}" if not rv
    rv
  end

  def milestone_index(m)
    rv = Milestone_index[m]
    raise "no milestone #{m}" if not rv
    rv
  end

  def comp_index(c)
    rv = Comp_index[c]
    raise "no complexity #{c}" if not rv
    rv
  end
  
  def load(r)
    return 0 if r.status == "cancelled" or r.status == "feedback"
    Loads[wp_index(r.work_package)+milestone_index(r.milestone)][comp_index(r.complexity)]
  end
  
  def workload(rs)
    rs.inject(0.0) { |sum, r| sum + load(r)}
  end
  
  def report_by(title, rs, id)
    rv  = "<a href='#' onclick=\"$('#{id}_#{title}').toggle();return false;\">"
    rv += ((title=="" ? "(empty)":title) + "</a>: <b>#{rs.size}</b> (#{workload(rs)}j.)<br/>")
    rv += "<ul id='"+id+"_"+title+"' style='display:none'>"
    rv += "<table><tr class='theader'><td>#</td><td>WS</td><td>Project</td><td>PM</td><td>Type</td><td>Miles.</td><td>Status</td><td>Resp</td><td>Load</td><td>Start date</td><td>Progress</td><td>SDP</td></tr>"
    rs.each { |r|
      rv += ("<tr class='#{sanitize(r.status)}'><td>#{r.request_id.to_i}</td><td>#{r.workstream}</td><td><a href='http://toulouse.sqli.com/EMN/view.php?id=#{r.request_id.to_i}'>" + r.summary + "</a></td><td>#{r.pm}</td><td>#{r.work_package}</td><td>#{r.milestone}</td><td><b>" +  r.status + "</b></td><td>#{r.assigned_to}</td><td>#{load(r)}</td><td>#{r.start_date.to_s}</td><td>#{r.resolution}<td>")
      rv += "<b>" if r.sdp == "No"
      rv += " SDP:" + r.sdp if r.sdp
      rv += "</b>" if r.sdp == "No"
      rv += "</td></tr>"
      }
    rv += "</table>"
    rv += "</ul>"
  end      

end
