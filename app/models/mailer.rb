class Mailer < ActionMailer::Base

    def mail(recipient)
      @from         = "faivrem@gmail.com" #"mfaivremacon@sqli.com"
      @recipients   = recipient
      @subject      = "Hi #{recipient}"
      @body["msg"]  = "youpi"
    end

end

