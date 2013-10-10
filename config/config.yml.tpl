# General
scpm_title: "SCPM Title"
scpm_address: "http://scpm.sqli.com"
project_name: "Your project code so you can configure display options"

# menu and access configuration
workloads_add_by_request_number: true
workloads_add_by_sdp_task: true
workloads_add_by_project: false
workloads_view_by_project_menu: false
plannings_menu: false
use_virtual_people: false
workloads_suggested_request: true

# workloads
# display length in months
workloads_months: 6
workloads_display_project_name_in_lines: false
workloads_show_consolidation_filters: false
workloads_display_total_column: false
workloads_display_consumed_column: false
workloads_lines_sort: "[l.project_id, l.wl_type, l.display_name.upcase]"
project_workloads_lines_sort: "l.display_name.upcase"
workloads_max_height: 500
consolidation_alert_on_overworkload: false
consolidation_capped_next_weeks: false
automatic_except_line_addition: false
workloads_display_consumed_column: true
workloads_display_diff_between_consumed_and_planned_column: true
workloads_display_status_column: true

# SDP
use_multiple_projects_sdp_export: false
auto_link_task_to_project: false

# SDP Import Email
sdp_import_email_destination: "addressMail1@sqli.com,addressMail2@sqli.com"
sdp_import_email_object: "WriteObjectOfMailHere"

# Daily email
daily_reminder_email_source: "addressMail@sqli.com"
daily_reminder_email_destination: "addressMail1@sqli.com,addressMail2@sqli.com,addressMail3@sqli.com"
daily_reminder_email_object: "[SCPM] Reminders for "

# CI/Request reminder email
request_ci_reminder_email_source: "addressMail@sqli.com"
request_ci_reminder_email_destination: "addressMail1@sqli.com,addressMail2@sqli.com,addressMail3@sqli.com"
request_ci_reminder_email_object: "[SCPM] Requests/CI reminders for "

# SDP by type
sdp_by_type_order: "Yes,Suite,No,no_type"

# Requirements is_covered list
requirement_is_covered_list: "Yes,No,Partially"

# Test email address
test_email_address: "addressMail1@sqli.com"

# Generic mail address
generic_email_address: "addressMail1@sqli.com"

# Status change mail
status_change_email_source: "addressMail1@sqli.com"
status_change_email_destination: "addressMail1@sqli.com"

# Risk Change mail
risk_change_email_source: "addressMail1@sqli.com"
risk_change_email_destination: "addressMail1@sqli.com"

# Workload alert mail
workload_alerts_email_source: "addressMail1@sqli.com"
workload_alerts_email_destination: "addressMail1@sqli.com,addressMail2@sqli.com,addressMail3@sqli.com,addressMail4@sqli.com"