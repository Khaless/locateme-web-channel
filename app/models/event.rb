
class Event < KVBase

	property :name

	subkey :users, Redis::Set

	def publish(message)
		$redis.publish(kify(:topic, :event, @guid), message)
	end

	def add_user(user)
		raise "Invalid User" unless user.kind_of? User
		$redis.multi do
			users << user.guid
			user.events << @guid
			$redis.publish(kify(:topic, :user, user.guid), {:notification => :user_joined_event, :user => user.guid, :event => @guid }.to_json)
		end
	end
end
