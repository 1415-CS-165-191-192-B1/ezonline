class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # For debug purposes
  #
  # @param options
  # @param response_status
  # @return [void]
  def redirect_to(options = {}, response_status = {})
  ::Rails.logger.error("Redirected by #{caller(1).first rescue "unknown"}")
  super(options, response_status)
  end

  before_action :set_name

  # Sets the username display
  #
  # @return [void]
  def set_name 
    unless session[:user_id].nil?
      @name = User.get_username(session[:user_id])
    end
  end

  # Updates the user session
  #
  # @param user_id [Decimal]
  # @param user_admin [Decimal]
  # @return [void]
  def update_user_session user_id, user_admin
    session[:user_id] = user_id
    session[:user_admin] = user_admin
  end

  # Saves credentials (after login, refresh token)
  #
  # @param auth 
  # @return [void]
  def update_google_session auth
    session[:google_access] = auth.access_token 
    session[:google_refresh] = auth.refresh_token
    session[:expires_in] = auth.expires_in
    session[:issued_at] = auth.issued_at
  end

  # Updates the Vimeo session
  #
  # @param token
  # @param secret
  def update_vimeo_session token, secret
    session[:vimeo_token] = token
    session[:vimeo_secret] = secret
  end

  # Checks the login state of the user to Google
  #
  # @return [false] if the user is not logged in to Google
  def check_login_state
    redirect_to login_user_index_path unless session[:user_id]
    return false
  end

  # Checks the login state of the user to Vimeo
  #
  # @return [false] if the user is not logged in to Vimeo
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
  end
  # Authenticates a user (admin only)
  #
  # @return [true, false] true or false whether the user is authenticated or not
  # @note Called only when user is logged in, restrict access to admin
  # @note No need for rescue ActiveRecord::RecordNotFound
  def authenticate_admin
    if session[:user_id]
      @current_user = User.find session[:user_id]
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

  # Saves the login state
  #
  # @return [true, false]
  # @note Skip login if already logged in,
  #	initialize google client with existing credentials
  def save_login_state
    if session[:user_id]
      GoogleClient::set_access session[:google_access], session[:google_refresh], session[:expires_in], session[:issued_at]
  		redirect_to root_url
      return true
  	else
  		return false
  	end
  end

  # Saves the Vimeo login state
  #
  # @return [false]
  # @note Initialize vimeo client with existing credentials
  def save_vlogin_state
    VimeoClient::save_credentials(session[:vimeo_token], session[:vimeo_secret]) if session[:vimeo_token]
    return false
  end

end