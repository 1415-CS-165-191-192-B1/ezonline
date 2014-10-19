require 'google_client'

class UserController < ApplicationController
	before_filter :save_login_state, :only => [:login]	# if user already logged in, redirect somewhere else
	
	def home	# set as root
		GoogleClient::init
		redirect_to(:controller => 'user', :action => 'login')	# temporarily automatically redirect user to login
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
	    # puts user_info.name
	    # puts user_info.email
	    # puts user_info.id
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
    		@message = 'YOU HAVE NO PERMISSION TO USE THIS APPLICATION'
	    end
	  end
	
	end

	def list
		@users = User.all
	end

	def save 	# replace with method to add user to app users
		user = User.new
		user.id = 104044938106898565002
		user.username = 'Christiane Yee'
		user.email = 'christiane.yee@gmail.com'
		user.admin = 1

		user.save!
	end

end
