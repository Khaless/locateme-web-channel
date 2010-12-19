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
