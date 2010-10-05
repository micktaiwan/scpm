module ProjectsHelper

  def are_filtered
    session[:project_filter_workstream] or session[:project_filter_status] or session[:project_filter_supervisor] or session[:project_filter_qr] or session[:project_filter_text]
  end

  def display_status(s)
    rv = "<div id='status_#{s.id}'><div class='status_explanation'>"
    if s.updated_at
      rv += "<div class='status_date'>#{s.updated_at}"
      rv += "(<b>#{time_ago_in_words(s.updated_at)}</b>) "
      rv += html_status(s.status) + " "
      rv += link_to('Edit', :action=>'edit_status', :id=>s.id)
      rv += " "
      rv += link_to_remote(image_tag('cut.png'), :url=>{:controller=>'projects', :action=>'cut_status', :id=>s.id})
      rv += link_to_remote(image_tag('delete.gif'), :url=>{:controller=>'projects', :action=>'destroy_status', :id=>s.id}, :confirm=>"Sure?", :success=>"new Effect.SwitchOff('status_#{s.id}');")
      rv += "</div>"
    end
    rv += simple_format(s.explanation)
    rv += "</div>"
    rv += "<h3>Status change reason (#{html_status(s.project.old_status)} => #{html_status(s.project.last_status)})</h3>"
    rv += simple_format(s.reason)
    rv += "<h3>Operational Alert</h3>"
    rv += simple_format(s.operational_alert)
    rv += "<h3>Feedback</h3>"
    rv += simple_format(s.feedback)
    rv += "</div>"
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


end

