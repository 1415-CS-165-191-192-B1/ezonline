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

  def update_google_session auth # save credentials (after login, refresh token)
    session[:google_access] = auth.access_token 
    session[:google_refresh] = auth.refresh_token
    session[:expires_in] = auth.expires_in
    session[:issued_at] = auth.issued_at
  end

  def update_vimeo_session token, secret
    session[:vimeo_token] = token
    session[:vimeo_secret] = secret
  end

  protected
  def check_login_state
    unless session[:user_id]
      redirect_to login_user_index_path
    end
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

  def authenticate_admin # called only when user is logged in, restrict access to admin
    if session[:user_id]
      @current_user = User.find session[:user_id] # no need for rescue ActiveRecord::RecordNotFound
      GoogleClient::set_access session[:google_access], session[:google_refresh], session[:expires_in], session[:issued_at]
      unless @current_user.admin
        redirect_to root_url
      end # end unless
      return true
    else
      redirect_to login_user_index_path
      return false
    end # end if condition
  end

  def save_login_state # skip login if already logged in, initialize google client with existing credentials
    if session[:user_id]
      GoogleClient::set_access session[:google_access], session[:google_refresh], session[:expires_in], session[:issued_at]
  		redirect_to root_url
      return true
  	else
  		return false
  	end
  end

  def save_vlogin_state # initialize vimeo client with existing credentials
    VimeoClient::save_credentials(session[:vimeo_token], session[:vimeo_secret]) if session[:vimeo_token]
    return false
  end

end
