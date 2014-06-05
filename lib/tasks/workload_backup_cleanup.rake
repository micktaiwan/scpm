# Delete all old backups
namespace :workload do
  task :backup_cleanup => :environment do
  include ApplicationHelper
  	current_week = wlweek(Date.today)
  	backupsToDelete = WlBackup.destroy_all(["week < ?", current_week.to_s])

  end
end