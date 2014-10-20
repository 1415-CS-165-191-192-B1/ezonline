require 'google_client'

class UserController < ApplicationController
	before_filter :save_login_state, :only => [:login]	# if user already logged in, redirect somewhere else
	before_filter :authenticate_admin, :only => [:requests_list] # if user not admin, restrict access
	respond_to :html, :js
	
	def show
		@users = User.all
	end

	def home	# set as root
		GoogleClient::init
		redirect_to(:controller => 'user', :action => 'login')	# temporarily automatically redirect user to login
	end

	def logout
		session.clear
	end

	def login
		GoogleClient::authorize	# redirect to google login
	end

	def get_code	# exchange code for access token, called upon redirection from google
		if params[:code]
			code = params[:code]
			GoogleClient::fetch_token code
			save_credentials
		end
	end

	def save_credentials	# after user logs in, store state in session
	  result = GoogleClient::fetch_user
	  user_info = nil

	  if result.status == 200
	    user_info = result.data
	  else
	    puts "An error occurred: #{result.data['error']['message']}"
	  end

	  if user_info != nil && user_info.id != nil

p user_info.id
p user_info.email
p user_info.name

	    begin
	    user = User.find(user_info.id)	# if user is authorized to use app
	    session[:user_id] = user_info.id
	    session[:user_admin] = user.admin

	    api_client = GoogleClient::retrieve	# get current instance of google client

	   	session[:access_token] = api_client.authorization.access_token	# save credentials
		session[:refresh_token] = api_client.authorization.refresh_token
		session[:expires_in] = api_client.authorization.expires_in
		session[:issued_at] = api_client.authorization.issued_at

	    @message = 'Logged in as ' + user_info.name 	

	    redirect_to(:controller => 'file', :action => 'get')	# temporarily redirects to /file/get to test functionality

   	    rescue ActiveRecord::RecordNotFound
   	    	begin 
	   	    	request = Request.new
	   	    	request.user_id = user_info.id
	   	    	request.email = user_info.email
	   	    	request.username = user_info.name
	   	    	request.save!
   	    	rescue ActiveRecord::RecordNotUnique
   	    		@message = 'A REQUEST WAS ALREADY SENT TO THIS APPLICATION. Please try again later.'
   	    	end # end rescue ActiveRecord::RecordNotFound
    		@message = 'YOU HAVE NO PERMISSION TO USE THIS APPLICATION. A request was sent to grant access.'
	    end # end rescue ActiveRecord::RecordNotFound
	  end
	end

	def requests_list
		@requests = Request.all
	end

	def destroy # add user from requests - destroy from requests
		@request = Request.find(params[:id])
		user = User.new
		user.user_id = @request.user_id
		user.email = @request.email
		user.username = @request.username
		user.save!
		@request.destroy!
		@requests = Request.all
	end

end
