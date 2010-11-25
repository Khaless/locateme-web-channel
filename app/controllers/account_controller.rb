class AccountController < ApplicationController

	skip_before_filter :http_authenticate, :only => [ :login, :register ]
	before_filter :redirect_to_main_if_logged_in, :only => [ :login, :register, :success ]

	def redirect_to_main_if_logged_in
		redirect_to :action => :main unless user.nil?
	end

	def register
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
			redirect_to :action => :success
			return
		end

		respond_to do |format|
			format.html # register.html.haml
		end
	end

	def success
	end

	def login
		if request.post?
			begin
				# Attempt to authenticate.
				# - User.find_by_email will raise an exception if the user cannot be found
				# - We explicitly raise an exception if user.authenticate? returns false.
				# We catch any exceptions and transform them to a logon failure message.
				u = User.find_by_email(params["email"]) 
				raise "Invalid Password" unless u.authenticate?(params["password"]) 

				# If we are here, no exceptions were raised and the user is
				# authenticated.
				set_current_user(u)
				redirect_to :action => :main
				return false

			rescue Exception => e
				@error = "Invalid Username/Password"
			end

		end
		respond_to do |format|
			format.html # register.html.haml
		end
	end

	def logout
	end

	def main

	end


end
