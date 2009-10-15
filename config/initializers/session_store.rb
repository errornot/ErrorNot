# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_error-logger_session',
  :secret      => 'e41bebb3a6595d92070c9f5f6f977045724b721bda9ef03406aa358ec6a1755ca2fcc9b6ab0bbf078534509aab8c6b6873701f52b4a158b64ce5dfa950cc732e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
