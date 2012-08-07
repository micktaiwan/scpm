# not beautful but.....
def protect_against_forgery?
	false
end

for p in Person.find(:all, :conditions=>"is_supervisor=0 and has_left=0 and is_transverse=0")
  requestHash   = p.get_request_reminder
  ciprojectHash = p.get_ciproject_reminder
  Mailer::deliver_daily_rmt_ci_reminder(p, requestHash, ciprojectHash) if requestHash.size > 0 or ciprojectHash.count > 0
end
