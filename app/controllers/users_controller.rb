require 'google_client'
require 'vimeo_client'

class UsersController < ApplicationController

	before_filter :save_login_state, :only => [:login]	# if user already logged in, redirect somewhere else
	before_filter :authenticate_admin, :only => [:requests_list, :show] # if user not admin, restrict access
	respond_to :html, :js

	def index	
	end

	def show
		@users = User.all
		@current_user_id = session[:user_id]
	end

	def contact
	end

	def home	# set as root		
		if session[:user_id]
			redirect_to(:controller => 'users', :action => 'index') and return
		else
			render layout: "home_temp"
			GoogleClient::init
		end
		#redirect_to(:controller => 'user', :action => 'login')	# temporarily automatically redirect user to login
	end

	def logout
		render layout: "home_temp"
		session.clear # only deletes app session, browser is still logged in to account
		GoogleClient::reset
		VimeoClient::reset
		VimeoModel::reset_session
	end

	def login
		render layout: "home_temp"
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

	    update_session GoogleClient::get_auth   	
		
	    @message = 'Logged in as ' + user_info.name 
	    @u_name = user_info.name	
	    redirect_to(:controller => 'user', :action => 'index') and return

   	    rescue ActiveRecord::RecordNotFound
   	    	GoogleClient::reset # effectively deleting access token for current client instance

   	    	begin 
	   	    	request = Request.new
	   	    	request.user_id = user_info.id
	   	    	request.email = user_info.email
	   	    	request.username = user_info.name
	   	    	request.save!
   	    	rescue ActiveRecord::RecordNotUnique
   	    		@message = 'A request was already sent to the application. Please try again later.'
   	    	end # end rescue ActiveRecord::RecordNotFound
    		@message = 'Sorry, you have no permission to use this application. A request was sent to grant access.'
	    end # end rescue ActiveRecord::RecordNotFound
	  end
	end

	def vlogin
		VimeoClient::reset
		session[:vimeo_oauth] = VimeoClient::fetch_oauth
		
		session[:return_to] = request.referer
		redirect_to VimeoClient::fetch_url
	end

	def vauthentication
		base = VimeoClient::retrieve
		access_token = base.get_access_token(params[:oauth_token], session[:vimeo_oauth], params[:oauth_verifier])

		session[:vimeo_token] = access_token.token
		session[:vimeo_secret] = access_token.secret
		session[:page] = 1

		VimeoModel::set_session session[:vimeo_token], session[:vimeo_secret], session[:page]

		redirect_to session.delete(:return_to)
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

		render :show
	end

	def unauthorize
		user_id = params[:id]
		user = User.find(user_id)
		User.find(user_id).delete

		render :text => "You successfully unauthorized" + user.username, :layout => true
	end

end