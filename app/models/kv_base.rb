
=begin

A thin wrapper around Redis and Redis-Objects
to manage our key namespaces

=end

require 'redis'
require 'redis/objects'
require 'redis/list'
require 'redis/value'
require 'redis/counter'
require 'redis/set'

class KVBase
		
	attr_reader :guid

	include Redis::Objects

	def initialize(guid=nil)
		if guid.nil?
			# No guid passed. Create a new guid
			@guid = UUIDTools::UUID.random_create.to_s
			if ($redis.hsetnx(kify(self.class.name, @guid), "created", Time.now.to_s) == 0)
				raise "Key Collision"
			end
		else
			@guid = guid
			raise sprintf("%s[%s] not found", self.class.name, guid) unless $redis.exists(kify(self.class.name, @guid))
		end
		@properties = Redis::HashKey.new(kify(self.class.name, @guid))
	end

	class << self

		# become a field in the hash with key <obj>:<guid>
		def property(__name, properties={})

			self.send(:define_method, __name) do
				self.instance_eval do
					@properties[__name] || ""
				end
			end

			if properties[:provide_indirection] == true

				# this property becomes a 'unique index'
				# indirection:<classname>:<__name> = guid
				# We must  maintain this index key
				# as well as the normal value
				self.send(:define_method, __name.to_s + "=") do |val|
					self.instance_eval do
						
						# Todo: if we already have a value, remove the old indirection
						
						# Would be better do both of these sets atomically
						if $redis.setnx(kify(:indirection, self.class.name, __name, val), @guid) != true
							raise "Indirection Collision"
						end
						@properties[__name] = val

					end
				end
				 
				# we also define a class method,
				# find_by_<indirection>
				(class << self; self; end).send(:define_method, "find_by_" + __name.to_s) do |v|
					guid = $redis.get(kify(:indirection, self.name, __name, v))
					raise sprintf("%s[%s=%s] not found", self.name, __name, v) if guid.nil? or guid.blank?
					self.find_by_guid(guid)
				end


			else
				# standard property setter.
				self.send(:define_method, __name.to_s + "=") do |val|
					self.instance_eval do
						@properties[__name] = val
					end
				end
			end
		end

		# become a subkey, i.e. a key of prefix <obj>:<guid>:<__name>
		def subkey(__name, __type)
			self.send(:define_method, __name) do
				key = kify(self.class.name, self.guid, __name)
				__type.new(key)
			end
		end

		def find_by_guid(guid)
			self.new(guid)
		end
	
		# Key-a-fi = Make an array of stuff into a redis key
		def kify(*args)
			args.map(&:to_s).map(&:downcase).join(":")
		end


	end
		
	def to_json(opt)
		{ :guid => @guid }.merge(@properties.all).to_json(opt)
	end

	def kify(*args)
		KVBase.kify(*args)
	end

end
