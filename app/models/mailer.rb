class Mailer < ActionMailer::Base

    def mail(recipient)
      @from         = "mfaivremacon@sqli.com"
      @recipients   = recipient
      @subject      = "Hi #{recipient}"
      @body["msg"]  = "youpi"
    end

end

