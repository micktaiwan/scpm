module ProjectsHelper

  def are_filtered
    session[:project_filter_workstream] or session[:project_filter_status] or session[:project_filter_supervisor] or session[:project_filter_qr] or (session[:project_filter_text] and session[:project_filter_text] != '')
  end

  def display_status(s)
    rv = "<div id='status_#{s.id}'><div class='status_explanation'>"
    if s.updated_at
      rv += "<div class='status_date'>#{s.updated_at}"
      rv += "(<b>#{time_ago_in_words(s.updated_at)} - w#{s.updated_at.to_date.cweek}</b>) "
      rv += html_status(s.status) + " "
      rv += link_to_function('Edit', "edit(#{s.id}, #{s.is_current?}, #{s.project.has_requests});") + " "
      if current_user.has_role?('Admin')
        rv += link_to_remote(image_tag('cut.png'), :url=>{:controller=>'projects', :action=>'cut_status', :id=>s.id})
        rv += link_to_remote(image_tag('delete.gif'), :url=>{:controller=>'projects', :action=>'destroy_status', :id=>s.id}, :confirm=>"Sure?", :success=>"new Effect.SwitchOff('status_#{s.id}');")
      end
      rv += "</div><br/>"
    end
    rv += "Last eReporting update:#{s.ereporting_date}"
    rv += "<table><tr><td>"
    rv += simple_format(s.explanation)
    rv += "</td><td class='diff'><br/>"
    rv += s.explanation_diffs.to_s
    rv += "</td></tr>"
    rv += "<tr><td valign='top'>"
    rv += "<h4>Last Change</h4>"
    rv += simple_format(s.last_change)
    rv += "</td><td class='diff'><br/><br/><br/>"
    rv += s.last_change_diffs.to_s
    rv += "</td></tr></table>"
    rv += "<br/>"

    if current_user.has_role?('Admin')
      rv += link_to_remote('Mark as read', {:url=>{:controller=>'projects', :action=>'mark_as_read', :id=>@project.id}, :success=>"$('markasread').fade();"}, {:class=>'btnlnk special', :id=>'markasread'})
    end


    if s.project
      rv += "<h3>Status change reason (#{html_status(s.project.old_status)} => #{html_status(s.project.last_status)})</h3>"
      rv += simple_format(s.reason)
      rv += "<h3>Operational Alert</h3>"
      rv += simple_format(s.operational_alert)
      rv += "<h3>Actions</h3>"
      rv += simple_format(s.actions)
      rv += "<h3>Feedback</h3>"
      rv += simple_format(s.feedback)
    end
    rv += "</div></div>"
    rv
  end

  def html_status(s)
    case s
      when 0; "<span class='status unknown'>unknown</span>"
      when 1; "<span class='status green'>green</span>"
      when 2; "<span class='status amber'>amber</span>"
      when 3; "<span class='status red'>red</span>"
    end
  end

  def text_status(s)
    case s
      when 0; "Unknown"
      when 1; "GREEN"
      when 2; "AMBER"
      when 3; "RED"
    end
  end

  def status_excel_style1(s)
    case s
      when 0; 's77'
      when 1; 's78'
      when 2; 's79'
      when 3; 's80'
    end
  end

  def status_excel_style2(s)
    case s
      when 0; 's81'
      when 1; 's82'
      when 2; 's83'
      when 3; 's84'
    end
  end

  def request_style(r)
    case r.status
      when 'to be validated'; 's85'
      when 'feedback';        's86'
      when 'new';             's87'
      when 'acknowledged';    's88'
      when 'performed';       's89'
    end
  end

  def excel_text(txt)
    return "" if not txt
    txt.split("\r\n").join('&#10;')
  end

end

