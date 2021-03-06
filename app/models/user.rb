
class User < KVBase

	property :email, :provide_indirection => true
	property :hashed_password
	property :salt

	subkey :events, Redis::Set
	subkey :location, Redis::Value

	def password=(password)
		self.salt = UUIDTools::UUID.random_create.to_s if self.salt.blank?
		self.hashed_password = Digest::SHA256.hexdigest(password + self.salt)
	end

	def authenticate?(plain_password)
		Digest::SHA256.hexdigest(plain_password + self.salt) == self.hashed_password
	end

	alias _location location
	def location
		ActiveSupport::JSON.decode(_location.value) rescue nil
	end

	# Temporary hack as we do not have a name/alias field yet
	def name
		return self.email 
	end

end
