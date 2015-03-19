require 'google_client'
require 'vimeo_client'

class UserController < ApplicationController
	before_action :save_login_state, :only => [:login]	# if user already logged in, redirect somewhere else
	before_action :authenticate_admin, :only => [:requests_list, :show] # if user not admin, restrict access

	def index		
		user = User.find(session[:user_id])
		if user.admin
			redirect_to admin_index_user_index_path
			return
		end

		#tasks = Task.where(user_id: session[:user_id]) # this causes an error, dk why
		user = User.find(session[:user_id])
		tasks = Task.where(user_id: user.user_id)
		@files = Hash.new # hash of doc => snippets
		@details = Hash.new

		render layout: "application_user"

		unless tasks.nil?
			tasks.each do |task|
				docs = Doc.where(doc_id: task.doc_id)
			    docs.each do |doc|
			      id = doc.read_attribute('doc_id')
			      @files[doc] = Snippet.where(doc_id: id)
			    
			      hash = {:done => task.done, :note => task.note}
			      @details[doc.doc_id] = hash
			    end
			end
	    end
	end

	def admin_index
		# notifs = Notif.find_by from_id: session[:user_id]
		user = User.find(session[:user_id])
		notifs = Notif.where(to_id: user.user_id)
		@notifs = Array.new

		unless notifs.nil?
			notifs.each do |notif|
				user = User.find_by user_id: notif.from_id
				doc = Doc.find_by doc_id: notif.doc_id

				hash = {:id => notif.id, 
						:date => notif.created_at, 
						:username => user.username, 
						:docname => doc.docname,
						:responded => notif.responded}
				@notifs << hash
			end
		end
 	end

	def show
		@users = User.all
		@current_user_id = session[:user_id]
	end

	def contact
	end

	def home	# set as root		
		if session[:user_id]
			redirect_to index_path
			return
		else
			render layout: "home_temp"
			GoogleClient::init
		end
	end

	def logout
		render layout: "home_temp"
		session.clear # only deletes app session, browser is still logged in to account
		GoogleClient::reset
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
		
	    redirect_to root_url
	    return

   	    rescue ActiveRecord::RecordNotFound
   	    	render layout: "home_temp"
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
		session[:vimeo_oauth] = VimeoClient::fetch_oauth
		
		session[:return_to] = request.referer # save url where login was invoked
		redirect_to VimeoClient::fetch_url
	end

	def vauthentication
		base = VimeoClient::get_base
		access_token = base.get_access_token(params[:oauth_token], session[:vimeo_oauth], params[:oauth_verifier])

		session[:vimeo_token] = access_token.token
		session[:vimeo_secret] = access_token.secret

		VimeoModel::set_auth session[:vimeo_token], session[:vimeo_secret]
		VimeoModel::save_latest

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

		begin
			@request.delete
			user.save!
			flash[:success] = "You successfully authorized " + user.username
		rescue
			flash[:error] = "Failed to authorize " + user.username
		end

		@requests = Request.all
		redirect_to :back
		return
	end

	def unauthorize
		user_id = params[:id]
		user = User.find(user_id)

		user.delete
		if user.destroyed?
			flash[:success] = "You successfully unauthorized " + user.username
		else
			flash[:error] = "Failed to unauthorize " + user.username
		end

		redirect_to :back
		return
	end

	def notify
		user_id = session[:user_id] # currently logged in user
		doc_id = params[:id] # the file selected as done

		doc = Doc.find(doc_id)
		user = User.find(user_id)
		task = Task.find_by doc_id: doc.doc_id, user_id: user.user_id
		#task = Task.find_by doc_id: doc_id, user_id: user_id # fails bec of diff data types
		task.update_attribute :done, true

		notif = Notif.new
		notif.from_id = user_id
		notif.to_id = task.admin_id
		notif.doc_id = doc_id

		begin
			notif.save!
			flash[:success] = "A notification was sent to the admin."
		rescue
			flash[:success] = "Failed to send a notification to the admin."
		end

		redirect_to :back
		return
	end

	#def delete_notifs
	#	notif_ids = params[:notif_ids]
	#	if notif_ids
	#		notif_ids.each do |id|
	#			Notif.delete(id)
	#		end
	#		flash[:success] = 'Successfully deleted selected notifications.'
	#	else
	#		flash[:notice] = 'You did not select any notification to delete.'
	#	end
	#	redirect_to :back
	#end

	def respond
		@notif_id = params[:id]
	end

	def send_response
		notif = Notif.find(params[:notif_id])
		task = Task.find(notif.doc_id)

		if (params[:approved] == true)
			task.delete
		else
			task.update_attribute :done, false
			# temporary
			task.update_attribute :note, 'Changes are still needed.'
		end

		notif.update_attribute :responded, true

		flash[:success] = 'Successfully sent your response.'
		redirect_to admin_index_user_index_path
		return
	end

	def delete_notif
		notif = Notif.delete(params[:id])
		redirect_to :back
	end

end
