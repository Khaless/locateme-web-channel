class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  before_filter :http_authenticate

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
		return nil if session[:user_guid].nil?
		return @user unless @user.nil?
		return @user = User.find_by_guid(session[:user_guid]) rescue nil
	end

	# stores the supplied user into the current session
	def set_current_user(user)
		session[:user_guid] = user.guid
		@user = user
	end

end
