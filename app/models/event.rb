
class Event < KVBase

	ShortHashLength = 8
	ShortHashChars = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten

	property :name
	property :shorthash, :provide_indirection => true

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

	def create_shorthash
		return self.shorthash unless self.shorthash.blank?
		counter = 0
		begin
		self.shorthash = (0...ShortHashLength).map { ShortHashChars[rand(ShortHashChars.length)] }.join
		self.shorthash
		rescue Exception => e
			counter += 1
			retry if counter < 10
			raise e
		end
	end

end
