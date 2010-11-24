class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  before_filter :http_authenticate

  def http_authenticate

	end

	# Return an instance to the current logged on user or nil
	def user
	end

end
