require 'google_client'

class UserController < ApplicationController
	before_filter :save_login_state, :only => [:login]
	
	def home
		GoogleClient::init
		redirect_to(:controller => 'user', :action => 'login')
	end

	def login
		GoogleClient::authorize
	end

	def get_code
		if params[:code]
			code = params[:code]
			GoogleClient::set_code code
			GoogleClient::fetch_token
			session[:authorized] = 'true'

			get_user
		end
	end

	def get_user
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
	    user = User.find(user_info.id)
	    session[:user_id] = user_info.id
	    session[:user_admin] = user.admin
	    @message = 'Logged in as ' + user_info.name 	

	    redirect_to(:controller => 'file', :action => 'get')

   	    rescue ActiveRecord::RecordNotFound
    		@message = 'YOU HAVE NO PERMISSION TO USE THIS APPLICATION'
	    end
	  end
	
	end

	def list
		@users = User.all
	end

	def save
		user = User.new
		user.id = 104044938106898565002
		user.username = 'Christiane Yee'
		user.email = 'christiane.yee@gmail.com'
		user.admin = 1

		user.save!
	end

end
