for p in Person.find(:all, :conditions=>"is_supervisor=0 and has_left=0 and is_transverse=0")
  n   = p.new_notes
  r   = p.requests_to_close
  am  = p.late_amendments
  ac  = p.late_actions
  Mailer::deliver_daily(p,n,r,am,ac ) if n.size > 0 or r.size > 0 or am.size > 0 or ac.size > 0
end

