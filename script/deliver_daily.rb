p   = Person.find_by_email('aaladlouni@sqli.com')
n   = p.new_notes
r   = p.requests_to_close
am  = p.late_amendments
ac  = p.late_actions

Mailer::deliver_daily(p,n,r,am,ac )

