class UsersController < ApplicationController

	before_filter :setup_request

	# GET /users/:id
	def show
		render # show.html.haml
	end
	
	private

	def setup_request
		@user = User.find_by_guid(params[:id])
	end

end
