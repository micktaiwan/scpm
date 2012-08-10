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


  def report_by(title, rs, id, expanded = false, report = false)    
    title = "nil" if not title
    rv = ""
    if not expanded
      rv  += "<a href='#' onclick=\"$('#{id}_#{title}').toggle();return false;\">" if not report
      rv += ((title=="" ? "(empty)" : title) + "</a>: <b>#{rs.size}</b> (#{workload(rs)})<br/>")
      rv += "<ul id='"+id+"_"+title+"' style='display:none'>" if not report
    else
      rv = ((title=="" ? "(empty)" : title) + ": <b>#{rs.size}</b> (#{workload(rs)})<br/>")
      rv += "<ul id='"+id+"_"+title+"'>"
    end
    
    return rv if report
    
    rv += "<table><tr class='theader'><td>#</td><td>WS</td><td width='400'>Project</td><td width='200'>PM</td><td>Type</td><td>Miles.</td><td>Status</td><td>Resp</td><td>Load</td><td>Start date</td><td>End date</td><td>Progress</td><td>SDP</td></tr>"
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
   
  def ci_project_report_by(title, cis, id, expanded = false, dateType = "none")    
    # Title
    title = "nil" if not title
    rv = ""
    if not expanded
      rv  += "<a href='#' onclick=\"$('#{id}_#{title}').toggle();return false;\">"
      rv += ((title=="" ? "(empty)" : title) + "</a>: <b>#{cis.size}</b><br/>")
      rv += "<ul id='"+id+"_"+title+"' style='display:none'>"
    else
      rv = ((title=="" ? "(empty)" : title) + ": <b>#{cis.size}</b><br/>")
      rv += "<ul id='"+id+"_"+title+"'>"
    end
    
    # Content
    # Table header
    date_header_title = "Date review"
    if dateType.eql?("objective")
      date_header_title = "Date objective"
    end
    rv += "<table><tr class='theader'><td>#</td><td></td><td>Status</td><td>Visibility</td><td>Assigned to</td><td></td><td>Summary</td><td>Stage</td><td>SQLI #{date_header_title}</td><td>Airbus #{date_header_title}</td><td>Deployment #{date_header_title}</td><td>Kick-Off Date</td><td></td></tr>"
    # Table row
    cis.each { |p|
    	# Date
    	sqli_date = ""
    	airbus_date = ""
    	deployment_date = ""
    	late_css_sqli = ""
    	late_css_airbus = ""
    	late_css_deployment = ""
    	if(dateType.eql?("review"))
    	  sqli_date = p.sqli_validation_date_review
    	  airbus_date = p.airbus_validation_date_review
    	  deployment_date = p.deployment_date_review
      	late_css_sqli = CiProject.late_css(p.sqli_validation_date_review)
      	late_css_airbus = CiProject.late_css(p.airbus_validation_date_review)
      	late_css_deployment = CiProject.late_css(p.deployment_date_review)
  	  elsif(dateType.eql?("objective"))
        sqli_date = p.sqli_validation_date_objective
    	  airbus_date = p.airbus_validation_date_objective
    	  deployment_date = p.deployment_date_objective
        late_css_sqli = CiProject.late_css(p.sqli_validation_date_objective)
        late_css_airbus = CiProject.late_css(p.airbus_validation_date_objective)
        late_css_deployment = CiProject.late_css(p.deployment_date_objective)
      else
      	sqli_date = p.sqli_validation_date_review
      	airbus_date = p.airbus_validation_date_review
      	deployment_date = p.deployment_date_review
  	  end
      rv += "<tr class='#{p.sanitized_status}'>"
      rv += "<td><b>"+ link_to(p.external_id, "https://sqli.steering-project.com/mantis/view.php?id=#{p.internal_id}") + "</b></td>"
    	rv += "<td>#{p.order}</td>"
    	rv += "<td>#{p.status}</td>"
    	rv += "<td>#{p.visibility}</td>"
    	rv += "<td>#{p.assigned_to}</td>"
    	rv += "<td>"
    	if p.strategic==1
    	  rv += image_tag('danger.gif')
    	end
    	rv += "</td>"
    	rv += "<td>#{p.summary}</td>"
    	rv += "<td><b>#{p.short_stage}</b></td>"
      rv += "<td class=\"" + late_css_sqli + "\"><b>#{sqli_date}</b> #{p.sqli_delay}</td>"
    	rv += "<td class=\"" + late_css_airbus + "\"><b>#{airbus_date}</b> #{p.airbus_delay}</td>"
    	rv += "<td class=\"" + late_css_deployment + "\"><b>#{deployment_date}</b> #{p.deployment_delay}</td>"
    	rv += "<td> #{p.kick_off_date} </td>"
      rv += "</tr>"
      }
    rv += "</table>"
    rv += "</ul>"
  end
  
  def get_workpackage_name_from_summary(summary, default)
    wpn = summary.split(/\[([^\]]*)\]/)[3] 
    wpn = default if wpn == nil or wpn == ""
    wpn
  end
  
end

