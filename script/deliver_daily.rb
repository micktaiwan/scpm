# not beautful but.....
def protect_against_forgery?
	false
end

for p in Person.find(:all, :conditions=>"is_supervisor=0 and has_left=0 and is_transverse=0")
  n   = p.new_notes
  r   = p.requests_to_close
  am  = p.late_amendments
  ac  = p.late_actions
  open_milestones  = p.milestones_with_open_checklists
  tbv = p.tbv_based_on_wl
  ciprojectHash = p.get_ciproject_reminder
  
  # To plan and percent_planed
  p_workload = Workload.new(p.id)
  wl_to_plan = p_workload.remain_to_plan_days
  if p_workload.sdp_remaining_total == 0
    wl_percent_planned = 0
  else
    wl_percent_planned = (((p_workload.planned_total / p_workload.sdp_remaining_total)*100)/0.1).round * 0.1
  end
  
  
  Mailer::deliver_daily(p,n,r,am,ac, open_milestones, tbv, wl_to_plan, wl_percent_planned,ciprojectHash) if n.size > 0 or r.size > 0 or am.size > 0 or ac.size > 0 or open_milestones.size > 0 or tbv.size > 0 or wl_percent_planned < 80 or ciprojectHash.count > 0
end
