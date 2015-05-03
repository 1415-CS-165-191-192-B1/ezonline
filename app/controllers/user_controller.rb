require 'google_client'
require 'vimeo_client'

class UserController < ApplicationController
  before_action :check_login_state, :except => [:home, :login, :authentication, :verify_credentials, :logout]
  before_action :restrict_non_admin, :only => [:admin_index]
  before_action :set_access_from_session, :only => [:login]
  #
  #
  # @return [void]
  def index
    if session[:user_admin]
      redirect_to admin_index_user_index_path
      return
    end
    @files, @details = Task.get_all(session[:user_id])
    render layout: "application_user"
  end

  #
  #
  # @return [void]
  def admin_index
    p session[:user_id]
    @notifs = Notif.get_all(session[:user_id])
  end

  #
  #
  def voptions
  end

  #
  #
  # @return [void]
  def show
    @users = User.all
    @current_user_id = session[:user_id]
  end

  #
  #
  # @return [void]
  def contact
    user = User.find(session[:user_id])
    if !user.admin
      render layout: "application_user"
      return
    end
    render layout: "application"
  end

  #
  #
  # @return [void]
  # @note Set as root
  def home
    if session[:user_id]
      redirect_to index_path
      return
    else
      render layout: "home_temp"
    end
  end

  # Logout, Makes the user offline
  #
  # @return [void]
  def logout
    render layout: "home_temp"
    session.clear # only deletes app session, browser is still logged in to account
    VimeoClient::delete_credentials
  end

  # Login, Makes the user online
  #
  # @return [void]
  def login
    redirect_to GoogleClient::build_auth_uri  # redirect to google login
  end

  # Exchanges code for access token, called upon redirection from google
  #
  # @return [void]
  def authentication
    if params[:code]
      GoogleClient::fetch_token params[:code]
      verify_credentials
    end
  end

  # Verifies the credentials of the user
  #
  # @return [void]
  # @note After user logs in, store state in session
  def verify_credentials
    user_info = GoogleClient::get_user_info

    unless user_info == nil
      user = User.find_if_exists(user_info.id)  # if user is authorized to use app
      if user.nil?
        render layout: "home_temp"
        session.clear
        @message = Request.create_new(user_info.id, user_info.email, user_info.name)
        return
      end

      update_user_session(user.user_id, user.admin)
      update_google_session

      redirect_to root_url
      return
    end
    redirect_to user_login_path
  end

  # Handles Vimeo login
  #
  # @return [void]
  def vlogin
    session[:vimeo_oauth] = VimeoClient::fetch_oauth

    session[:return_to] = request.referer # save url where login was invoked
    redirect_to VimeoClient::fetch_url
  end

  # Handles Vimeo authentication
  #
  # @return [void]
  def vauthentication
    base = VimeoClient::get_base
    access_token = base.get_access_token(params[:oauth_token], session[:vimeo_oauth], params[:oauth_verifier])

    update_vimeo_session access_token.token, access_token.secret

    VimeoClient::save_credentials(session[:vimeo_token], session[:vimeo_secret])
    VimeoClient::save_latest

    redirect_to session.delete(:return_to)
  end

  # Lists all requests received by app
  #
  # @return [void]
  def requests_list
    @requests = Request.all
  end

  # Adds user from requests - destroys from requests
  #
  # @return [void]
  def destroy
    @request = Request.find(params[:id])
    @requests = Request.all
    type, message = User.create_new(params[:id])
    flash[type] = message
    redirect_to :back
  end

  # Unauthorizes the user
  #
  # @return [void]
  def unauthorize
    type, message = User.delete_and_respond(params[:id])
    flash[type] = message
    redirect_to :back
    return
  end

  #
  #
  # @return [void]
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

  # Responds to a notification
  #
  # @return [void]
  def respond
    @notif_id = params[:id]
  end

  # Sends response
  #
  # @return [void]
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

  # Deletes a notification
  #
  # @return [void]
  def delete_notif
    notif = Notif.delete(params[:id])
    redirect_to :back
  end

end
