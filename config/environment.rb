# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize our connection to Redis
$redis = Redis.new

# Initialize the rails application
WebChannel::Application.initialize!
