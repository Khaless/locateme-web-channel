class ApplicationController < ActionController::Base
  
  layout 'application'
  before_filter :http_authenticate
  protect_from_forgery

  def http_authenticate

  	# Return true & continue down the filter chain if the user is logged in.
  	return true unless user.nil?
  	
  	# For now, send back a http forbidden response and stop.
  	head :forbidden
  	return false

	end

	private
	
	# Return an instance to the current logged on user or nil
	def user
		guid = session[:user_guid]
		if guid.nil? and !request.headers["X-Authenticated-By-Proxy"].nil?
			# X-Authenticated-By-Proxy is valid for a request
			# coming in from the event proxy. Make sure this is valid
			# then set the user to whom the proxy wants. We also bypass
			# the authenticity token (csrf protection mechanism)
			# for a client authenticated by the proxy by rewriting the request 
			# to be whitelisted.
			@authenticated_by_proxy = true
			guid = request.headers["X-Authenticated-By-Proxy"]
			def request.forgery_whitelisted?; true; end
		end
		return nil if guid.nil?
		return @user unless @user.nil?
		return @user = User.find_by_guid(guid) rescue nil
	end

	# stores the supplied user into the current session
	def set_current_user(user)
		session[:user_guid] = user.guid
		@user = user
	end

end
