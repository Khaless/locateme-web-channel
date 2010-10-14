
class User

	attr_reader :guid

	# Method used to retrieve various properties
	PropertyMethods = {
		:topics => :smembers,
		:name		=> :get
	}

	def initialize(guid)
		# We Lazily get properties
		@guid = guid
		@properties = {}
	end

	def get_property(property)
		throw "Invalid Property" unless PropertyMethods.key?(property.to_sym)
		unless @properties.key?(property.to_sym)
			key = sprintf "user:%s:%s", @guid, property.to_s
			@properties[property.to_sym] = $redis.send(PropertyMethods[property.to_sym], key)
		end
		return @properties[property.to_sym]
	end

	class << self

		def all_guids
			$redis.keys("user:*").map do |key|
				# guid part if the key is User:guid of 36 Chr:<Anything>
				key[5,36]
			end
		end

		def by_guid(guid)
			User.new(guid)
		end

	end

end
