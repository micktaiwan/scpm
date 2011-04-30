class Mailer < ActionMailer::Base

  def mail(recipient, subject = "Hi", body = "Test de mail")
    @from        = "mfaivremacon@sqli.com"
    @recipients  = recipient
    @subject     = subject
    @body["msg"] = body
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

end

