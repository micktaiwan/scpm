# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'
  config.action_mailer.delivery_method = :sendmail
end

ActionMailer::Base.sendmail_settings = {
:location       => '/usr/sbin/sendmail',
:arguments      => '-i -t'
}

#ActionMailer::Base.sendmail_settings = {
#  :address => "smtp.gmail.com",
#  :port => 465,
#  :user_name => "mfaivremacon@sqli.com",
#  :password => "mickael003",
#  :authentication => :login
#  }

