
class Event < KVBase

	module Exceptions
		class InvalidParameter < StandardError; end
	end

	ShortHashLength = 8
	ShortHashChars = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten

	property :name
	property :shorthash, :provide_indirection => true
	property :creator

	subkey :users, Redis::Set

	def publish(message)
		$redis.publish(kify(:topic, :event, @guid), message)
	end

	def make_creator(user)
		raise Exceptions::InvalidParameter unless user.kind_of? User
		self.creator = user.guid
	end

	def is_creator(user)
		raise Exceptions::InvalidParameter unless user.kind_of? User
		self.creator == user.guid
	end

	def add_user(user)
		raise Exceptions::InvalidParameter unless user.kind_of? User
		$redis.multi do
			users << user.guid
			user.events << @guid
			$redis.publish(kify(:topic, :user, user.guid), {:notification => :user_joined_event, :user => user.guid, :event => @guid }.to_json)
		end
	end

	# Remove the user from the event
	# Warning: This call CAN remove the creator of the event
	# from the event, so controller logic should be checking
	# is_creator(user) first
	def remove_user(user)
		raise Exceptions::InvalidParameter unless user.kind_of? User
		$redis.multi do
			users.delete(user.guid)
			user.events.delete(@guid)
			$redis.publish(kify(:topic, :user, user.guid), {:notification => :user_left_event, :user => user.guid, :event => @guid }.to_json)
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
