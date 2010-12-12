=begin
Contains special methods which the event proxy may call
=end
class EventProxyApiController < ApplicationController

	skip_before_filter :verify_authenticity_token
	skip_before_filter :http_authenticate, :only => [ :authenticate_user ]
	before_filter :restrict_requests, :except => [:authenticate_user]


	def restrict_requests
		if !request.post?
			render :status => 400, :text => "Bad Request"
			return false
		end
		if @authenticated_by_proxy != true
			render :status => 403 , :text => "Forbidden"
			return false 
		end
	end

	def authenticate_user
		return render :status => 400, :text => "Bad Request"  unless request.post?
		return render :status => 403, :text => "Forbiden" if request.headers["X-Proxy-Authentication-Secret"] != "abcd123"
		begin
			u = User.find_by_email(params["email"]) 
			if u.authenticate?(params["password"]) 
				# User is authenticated. Respond with all required details for this client.
				state = {
					:guid => u.guid,
					:email => u.email,
					:events => u.events.map { |event_guid|
						e = Event.find_by_guid(event_guid)
						{ :guid => e.guid, :name => e.name, :users => e.users.map { |user_guid|
								eu = User.find_by_guid(user_guid)
								{ :guid => eu.guid, :name => eu.email, :location => eu.location }
							}
						}
					}
				}
				render :json => {:result => state, :error => nil}
				return
			end
		rescue Exception => e; p e; end
		render :json => {:result => nil, :error => "Authentication Failed"}

	end

end

