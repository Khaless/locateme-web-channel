# Initialize our connection to Redis
# if we are using cloud-foundry connect to the provisioned redis cf service
# otherwise connect to redis locally.
vcap_services = ActiveSupport::JSON.decode(ENV["VCAP_SERVICES"]) rescue nil
if vcap_services.nil?
	# We're local
	Rails.logger.info('Connecting to Redis (local)')
	$redis = Redis.new
else
	Rails.logger.info('Connecting to Redis (cloudfoundry) using: ' + vcap_services.inspect)
	redis_host = vcap_services["redis-2.2"][0]["credentials"]["hostname"]
	redis_port = vcap_services["redis-2.2"][0]["credentials"]["port"]
	redis_password = vcap_services["redis-2.2"][0]["credentials"]["password"]
	$redis = Redis.new :host => redis_host, :port => redis_port, :password => redis_password
end
