module ProjectsHelper

  def are_filtered
    session[:project_filter_workstream] or session[:project_filter_status] or session[:project_filter_supervisor] or session[:project_filter_qr] or (session[:project_filter_text] and session[:project_filter_text] != '')
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
    txt = txt.gsub(/<br>/i,"<br/>")
    txt.split("\r\n").join('&#10;')
  end

end

