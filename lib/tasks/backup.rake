require 'find'
require 'ftools'

namespace :db do
  desc "Backup the database to a file. Options: DIR=base_dir RAILS_ENV=production MAX=20"
  task :backup => [:environment] do
    datestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    base_path = ENV["DIR"] || "db"
    backup_base = File.join(base_path, 'backup')
    backup_folder = File.join(backup_base, datestamp)
    backup_file = File.join(backup_folder, "#{RAILS_ENV}_dump.sql.gz")
    File.makedirs(backup_folder)
    db_config = ActiveRecord::Base.configurations[RAILS_ENV]
    sh "mysqldump -u #{db_config['username']} -p#{db_config['password']} -Q --add-drop-table -O add-locks=FALSE -O lock-tables=FALSE #{db_config['database']} | gzip -c > #{backup_file}"
    dir = Dir.new(backup_base)
    all_backups = dir.entries[2..-1].sort.reverse
    puts "Created backup: #{backup_file}"
    max_backups = (ENV["MAX"] || 20).to_i
    puts "max backups: #{max_backups}"
    unwanted_backups = all_backups[max_backups..-1] || []
    for unwanted_backup in unwanted_backups
      FileUtils.rm_rf(File.join(backup_base, unwanted_backup))
      puts "deleted #{unwanted_backup}"
    end
    puts "Deleted #{unwanted_backups.length} backups, #{all_backups.length - unwanted_backups.length} backups available"
  end

############################################

  desc "Dump the current database to a MySQL file"
  task :database_dump do
    load 'config/environment.rb'
    abcs = ActiveRecord::Base.configurations
    case abcs[RAILS_ENV]["adapter"]
    when 'mysql'
      ActiveRecord::Base.establish_connection(abcs[RAILS_ENV])
      File.open("db/#{RAILS_ENV}_data.sql", "w+") do |f|
        if abcs[RAILS_ENV]["password"].blank?
          f << `mysqldump -h "localhost" -u #{abcs[RAILS_ENV]["username"]} #{abcs[RAILS_ENV]["database"]}`
        else
          f << `mysqldump -h "localhost" -u #{abcs[RAILS_ENV]["username"]} -p#{abcs[RAILS_ENV]["password"]} #{abcs[RAILS_ENV]["database"]}`
        end
      end
    else
      raise "Task not supported by '#{abcs[RAILS_ENV]['adapter']}'"
    end

    # TODO: zip data
    gzip "db/#{RAILS_ENV}_data.sql"
  end

  desc "Refreshes your local development environment to the current production database"
  task :production_data_refresh do
    `cap remote_db_runner`
    `rake db:production_data_load --trace`
  end


  desc "Loads the production data downloaded into db/production_data.sql into your local development database"
  task :production_data_load do
    load 'config/environment.rb'
    abcs = ActiveRecord::Base.configurations
    
    # TODO: unzip data
    unzip "db/#{RAILS_ENV}_data.gz"
    
    case abcs[RAILS_ENV]["adapter"]
    when 'mysql'
      ActiveRecord::Base.establish_connection(abcs[RAILS_ENV])
      if abcs[RAILS_ENV]["password"].blank?
        `mysql -u #{abcs[RAILS_ENV]["username"]} -D #{abcs[RAILS_ENV]["database"]} < db/production_data.sql`
      else
        `mysql -u #{abcs[RAILS_ENV]["username"]} -p#{abcs[RAILS_ENV]["password"]} -D #{abcs[RAILS_ENV]["database"]} < db/production_data.sql`
      end
    else
      raise "Task not supported by '#{abcs[RAILS_ENV]['adapter']}'"
    end
  end

end

