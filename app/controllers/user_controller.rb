require 'google_client'
require 'vimeo_client'

class UserController < ApplicationController
  before_action :check_login_state, :except => [:login, :authentication, :verify_credentials, :logout]
  before_action :restrict_non_admin, :only => [:admin_index]

  def index    
    if session[:user_admin]
      redirect_to admin_index_user_index_path
      return
    end
    @files, @details = Task.get_all(session[:user_id])
    render layout: "application_user"
  end

  def admin_index
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

  def voptions
  end

  def show
    @users = User.all
    @current_user_id = session[:user_id]
  end

  def contact
    user = User.find(session[:user_id])
    if !user.admin
      render layout: "application_user"
      return
    end
    render layout: "application"
  end

  def home  # set as root    
    if session[:user_id]
      redirect_to index_path
      return
    else
      render layout: "home_temp"
    end
  end

  def logout
    render layout: "home_temp"
    session.clear # only deletes app session, browser is still logged in to account
    GoogleClient::delete_credentials
    VimeoClient::delete_credentials
  end

  def login
    redirect_to GoogleClient::build_auth_uri  # redirect to google login
  end

  def authentication  # exchange code for access token, called upon redirection from google
    if params[:code]
      code = params[:code]
      GoogleClient::fetch_token code
      verify_credentials
    end
  end

  def verify_credentials  # after user logs in, store state in session
    user_info = GoogleClient::get_user_info

    unless user_info == nil
      user = User.find_if_exists(user_info.id)  # if user is authorized to use app
      if user.nil?
        render layout: "home_temp"
        GoogleClient::delete_credentials # effectively deleting access token for current client instance
        @message = Request.create_new(user_info.id, user_info.email, user_info.name)
        return
      end
      update_user_session(user.user_id, user.admin)
      redirect_to root_url
      return
    end
    redirect_to user_login_path
  end

  def vlogin
    session[:vimeo_oauth] = VimeoClient::fetch_oauth
    
    session[:return_to] = request.referer # save url where login was invoked
    redirect_to VimeoClient::fetch_url
  end

  def vauthentication
    base = VimeoClient::get_base
    access_token = base.get_access_token(params[:oauth_token], session[:vimeo_oauth], params[:oauth_verifier])

    update_vimeo_session access_token.token, access_token.secret

    VimeoClient::save_credentials(session[:vimeo_token], session[:vimeo_secret])
    VimeoClient::save_latest

    redirect_to session.delete(:return_to)
  end

  def requests_list # lists all requests received by app
    @requests = Request.all
  end

  def destroy # add user from requests - destroy from requests
    @request = Request.find(params[:id])
    @requests = Request.all
    type, message = User.create_new(params[:id])
    flash[type] = message
    redirect_to :back
  end

  def unauthorize
    type, message = User.delete_and_respond(params[:id])
    flash[type] = message
    redirect_to :back
    return
  end

  def notify
    type, message = Notif.create_new(session[:user_id], params[:id])
    flash[type] = message
    redirect_to :back
    return
  end

  #def delete_notifs
  #  notif_ids = params[:notif_ids]
  #  if notif_ids
  #    notif_ids.each do |id|
  #      Notif.delete(id)
  #    end
  #    flash[:success] = 'Successfully deleted selected notifications.'
  #  else
  #    flash[:notice] = 'You did not select any notification to delete.'
  #  end
  #  redirect_to :back
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
