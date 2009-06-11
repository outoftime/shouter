# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_mock_app_session',
  :secret      => 'a6efed059e7d589ba68ae4499e6c94fb8549595a8ebe3e3b1bd2d68d7e6510a310f200b19507f76cbfc70c1084f5fdfd1361870f0b8fbc656ca63873e1d4c952'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
