class Mailer < ActionMailer::Base

  def mail(recipient, subject = "Hi", body = "Test de mail")
    @from        = "mfaivremacon@sqli.com"
    @recipients  = recipient
    @subject     = subject
    @body        = body
    content_type "text/html; charset=utf-8"
  end

  def status_change(project)
    @from       = "mfaivremacon@sqli.com"
    @recipients = "mfaivremacon@sqli.com"
    @subject    = "[EISQ] Status change - #{project.full_name}"
    @project    = project
  end

  def risk_change(risk)
    @from       = "mfaivremacon@sqli.com"
    @recipients = "mfaivremacon@sqli.com"
    @subject    = "[EISQ] Risk change - #{risk.project.full_name}"
    @risk       = risk
  end

  # search all people without work and send a reminder to update the workload
  def workload_alerts
    people = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0 and is_transverse=0", :order=>"name")
    @workloads = []
    for p in people
      @workloads << Workload.new(p.id)
    end
    @workloads = @workloads.select{|w| w.next_month_percents < 95 or w.next_month_percents > 115}.sort_by {|w| [w.next_month_percents]}

    @from       = "mfaivremacon@sqli.com"
    @recipients = "mfaivremacon@sqli.com"
    @subject    = "[EISQ] Workload alerts"
    @headers    = {}
    content_type "text/html; charset=utf-8"
  end

  def daily(person, n, r, am, ac, om)
    render(:nothing=>true) and return if !person or person.email.empty?
    @from        = "mfaivremacon@sqli.com"
    @recipients  = "#{person.email}, mfaivremacon@sqli.com"
    @subject     = "[BAM] Reminders for #{person.name}"
    @person, @new_notes, @requests_to_close, @amendments, @actions, @milestones_with_open_checklists = person, n, r, am, ac, om
    content_type "text/html; charset=utf-8"
  end
end
