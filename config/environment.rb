# Load the Rails application.
require_relative 'application'

# mailer host
config.action_mailer.default_url_options = { :host => 'panda-pto-test.herokuapp.com' }

# Initialize the Rails application.
Rails.application.initialize!
