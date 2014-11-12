require 'google_client'
require 'vimeo_client'

class UserController < ApplicationController
	before_filter :save_login_state, :only => [:login]	# if user already logged in, redirect somewhere else
	before_filter :authenticate_admin, :only => [:requests_list, :show] # if user not admin, restrict access
	respond_to :html, :js

	def show
		@users = User.all
	end

	def home	# set as root
		GoogleClient::init
		#redirect_to(:controller => 'user', :action => 'login')	# temporarily automatically redirect user to login
	end

	def logout
		session.clear # only deletes app session, browser is still logged in to account
		GoogleClient::reset
	end

	def login
		GoogleClient::authorize	# redirect to google login
	end

	def authentication	# exchange code for access token, called upon redirection from google
		if params[:code]
			code = params[:code]
			GoogleClient::fetch_token code
			verify_credentials
		end
	end

	def verify_credentials	# after user logs in, store state in session
	  result = GoogleClient::fetch_user
	  user_info = nil

	  if result.status == 200
	    user_info = result.data
	  else
	    puts "An error occurred: #{result.data['error']['message']}"
	  end

	  if user_info != nil && user_info.id != nil

		#p user_info.id 		# print details
		#p user_info.email
		#p user_info.name

	    begin
	    user = User.find(user_info.id)	# if user is authorized to use app
	    session[:user_id] = user_info.id
	    session[:user_admin] = user.admin

	    api_client = GoogleClient::retrieve	# get current authorized instance of google client

	   	session[:google_access] = api_client.authorization.access_token	# save credentials
		session[:google_refresh] = api_client.authorization.refresh_token
		session[:expires_in] = api_client.authorization.expires_in
		session[:issued_at] = api_client.authorization.issued_at

		puts '======'
		puts session[:expires_in]

	    @message = 'Logged in as ' + user_info.name 	

   	    rescue ActiveRecord::RecordNotFound
   	    	GoogleClient::reset

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

	def vlogin
		VimeoClient::reset
		session[:vimeo_oauth] = VimeoClient::fetch_oauth
		redirect_to VimeoClient::fetch_url
	end

	def vauthentication
		base = VimeoClient::retrieve
		access_token = base.get_access_token(params[:oauth_token], session[:vimeo_oauth], params[:oauth_verifier])

		session[:vimeo_access] = access_token.token
		session[:vimeo_secret] = access_token.secret

		redirect_to new_file_path
	end

	def requests_list # lists all requests received by app
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
