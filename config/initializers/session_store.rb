# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_eisq_session',
  :secret      => 'f71b916ade6b24acbf2931753298ec38ee37a2dd303d3049333b5b4647b31ffc2094c5330924e67b3d53ee28b1537ea27225257accc43a6e97762dcc2aeef84b'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
