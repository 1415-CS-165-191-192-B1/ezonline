class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def redirect_to(options = {}, response_status = {}) # for debug purposes
  ::Rails.logger.error("Redirected by #{caller(1).first rescue "unknown"}")
  super(options, response_status)
  end

  before_action :set_name

  def set_name 
    # sets the username display
    unless session[:user_id].nil?
      @name = User.get_username(session[:user_id])
    end
  end

  def update_user_session user_id, user_admin
    session[:user_id] = user_id
    session[:user_admin] = user_admin
  end

  def check_login_state
    redirect_to login_user_index_path unless session[:user_id]
    return false
  end

  def check_vlogin_state
    unless session[:vimeo_token]
      redirect_to vlogin_user_path
    else
      VimeoClient::save_credentials(session[:vimeo_token], session[:vimeo_secret])
    end
    return false
  end

  def restrict_non_admin
    redirect_to root_url unless session[:user_admin]
    return false
  end

end
