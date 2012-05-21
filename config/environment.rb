# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

if Gem::VERSION >= "1.3.6" 
    module Rails
        class GemDependency
            def requirement
                r = super
                (r == Gem::Requirement.default) ? nil : r
            end
        end
    end
end

# rake gems:install
Rails::Initializer.run do |config|
  config.time_zone = 'UTC'
  config.action_mailer.delivery_method = :sendmail
  #config.gem 'ruby-net-ldap', :version => '0.0.4', :lib => 'net/ldap'
  #config.gem 'differ', :version=> '0.1.2'
  #config.gem 'will_paginate', :version => '2.3.16'
  #config.gem 'gchartrb' # 1.6.8 ?
end

ActionMailer::Base.sendmail_settings = {
  :location       => '/usr/sbin/sendmail',
  :arguments      => '-i -t'
}
