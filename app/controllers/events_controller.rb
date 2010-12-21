class EventsController < ApplicationController

	before_filter :setup_request, :except => [ :create, :new, :index ]

	def new
		respond_to do |format|
			format.html # new.html.haml
		end
	end

	# POST /events/
	def create
		event = Event.new
		event.name = params[:name]
		event.make_creator(user)
		event.add_user(user)
		event.create_shorthash # For now, always create optional shorthash
		respond_to do |format|
			format.html do
				redirect_to :action => :show, :id => event.guid
			end
			format.json do
				render :status => 201, :json => event # 201 Created
			end
		end
	end

	# POST /event/<id>/join
	def join
		@event.add_user(user)
		respond_to do |format|
			format.html do
				redirect_to :action => :show, :id => event.guid
			end
			format.json do
				render :status => 200, :json => {}
			end
		end
	end

	# POST /event/<id>/leave
	def leave
		if @event.is_creator(user)
			respond_to do |format|
				format.html do
					redirect_to event_url(@event.guid), :notice => "You are the creator of this event, you cannot be removed."
				end
				format.json do
					render :status => 412, :json => { :result => nil, :error => "You are the creator of this event, you cannt be removed."}
				end
			end
		else
			@event.remove_user(user)
			respond_to do |format|
				format.html do
					redirect_to events_url, :notice => "You have been removed from the event." 
				end
				format.json do
					render :status => 200, :json => {}
				end
			end
		end
	end

	def index
		
		# Produce a list of Events this user belongs to
		@events = user.events.map { |guid| Event.find_by_guid(guid) }

	end

	def show
		# Grab a list of users in this event
		@users = @event.users.map { |guid| User.find_by_guid(guid) }
		respond_to do |format|
			format.html # show.html.haml
		end
	end

	def write
		@event.publish(params[:message])
		redirect_to :action => "show"
	end
	
	private

	def setup_request
		@event = Event.find_by_guid(params[:id])
	end

end
