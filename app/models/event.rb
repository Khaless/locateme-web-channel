
class Event < KVBase

	property :name

	subkey :users, Redis::Set

	def publish(message)
		$redis.publish(kify(:topic, @guid), message)
	end

end
