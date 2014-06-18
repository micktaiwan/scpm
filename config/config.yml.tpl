# General
scpm_title: "SCPM Title"
scpm_address: "http://scpm.sqli.com"
project_name: "Your project code so you can configure display options"
task_import_config: 'simple' # or multiple'

# report
report_timeline_count: 30 # Number of timeline displayed in the list of projects
report_spider_milestone_blacklist: # Milestones without spiders
    - M14
    - G9
    - sM14
    - CCB
report_milestones_eligible_for_note:
    - M3
    - G2
    - M5
    - G5
    - QG TD
    - M13
    - CCB
    
# menu and access configuration
workloads_add_by_request_number: true
workloads_add_by_sdp_task: true
workloads_add_by_project: false
workloads_view_by_project_menu: false
plannings_menu: false
use_virtual_people: false
workloads_suggested_request: true
workloads_use_financial_monitoring: false # Show or not related PP4 functions

# workloads
# display length in months
workloads_months: 6
workloads_display_project_name_in_lines: false
workloads_show_consolidation_filters: false
workloads_display_total_column: false
workloads_display_consumed_column: false
workloads_lines_sort: "[l.project_id, l.wl_type, l.display_name.upcase]"
project_workloads_lines_sort: "project_id,wl_type,name" # Order of wlline in workload
workloads_max_height: 500
consolidation_alert_on_overworkload: false
consolidation_capped_next_weeks: false
automatic_except_line_addition: false
workloads_display_consumed_column: true
workloads_display_diff_between_consumed_and_planned_column: true
workloads_display_status_column: true
workloads_show_filter: false # Show or hide the filter buttn
workload_holiday_threshold_before_backup: 2 # Number of holidays days which need the attribution of a backup
workload_show_overload_availability: false #Show on the availability parameters of workload if user is in overload
workload_show_negative_sum_availability: false 

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

# Backup delete mail
backup_change_email_source: "addressMail1@sqli.com"

# Workload alert mail
workload_alerts_email_source: "addressMail1@sqli.com"
workload_alerts_email_destination: "addressMail1@sqli.com,addressMail2@sqli.com,addressMail3@sqli.com,addressMail4@sqli.com"

# Load QS and spiders
qs_load: 0.375
spider_load: 0.375

# Summary export - workpackages which should be highlighted in the summary
    summary_workpackages_highlight: 
        - WP2
        - WP3.0
        - WP3.1
        - WP3.2
        - WP3.2.1
        - WP3.2.2
        - WP3.2.3
        - WP3.3
        - WP3.4
        - WP4
        - WP4.1
        - WP4.2
        - WP4.3
        - WP4.4
        - WP5
        - WP5.1
        - WP6.1
        - WP5.2
        - WP6.2
        - WP6.3
        - WP6.4
        - WP6.5
        - WP6.6
        - WP6.7
        - WP6.8
        - WP6.9
        - WP6.10.1
        - WP6.10.2
        - WP6.10.3
        - WP6.11
        - WP7.1
        - WP7.1.1
        - WP7.1.2
        - WP7.1.3
        - WP7.1.4
        - WP7.1.5
        - WP7.1.6
        - WP7.2
        - WP7.2.1
        - WP7.2.2
        - WP7.2.3
        - WP7.2.4
        - WP7.2.5
        - WP7.2.6
