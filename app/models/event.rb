
class Event

	def initialize(guid)
		raise "nil guid" if guid.blank?
		@guid = guid
	end

	def write(message)
		$redis.publish("topic:" + @guid, message)
	end

	def members
		$redis.smembers("event:" + @guid + ":users").map { |guid| User.by_guid(guid) }
	end

	class << self

		def by_guid(guid)
			Event.new(guid)
		end

	end
end
