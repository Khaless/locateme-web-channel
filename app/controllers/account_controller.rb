class AccountController < ApplicationController

	skip_before_filter :http_authenticate, :only => [ :login, :register ]

	def register
		redirect_to :show unless user.nil?

		if request.post?
			# Validate parameters (The redis data model does not
			# do it for us (yet... We dont want to provide an ORM but 
			# we do want to provide a way to validate fields and I think
			# the best place to do this is the model.)
			raise "Email is invalid" unless params["email"] =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
			raise "Password is invalid" if params["password"].length < 6

			# TODO: user model accept a dictionary of values which it can set with hmset after it
			# does its initial hsetnx (which it needs to avoid race conditions).
			u = User.new
			u.email = params["email"]
			u.password = params["password"]
			redirect_to :action => "success"
			return
		end

		respond_to do |format|
			format.html # register.html.haml
		end
	end

	def success
	end

	def login
	end

	def logout
	end


end
