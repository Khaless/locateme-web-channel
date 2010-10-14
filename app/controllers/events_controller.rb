class EventsController < ApplicationController

	before_filter :setup_request, :except => [ :index ]

	def setup_request
		@event = Event.by_guid(params[:id])
	end

	def index

	end

	def show

	end

	def write
		@event.write(params[:message])
		redirect_to :action => "show"
	end

end
