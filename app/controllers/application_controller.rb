class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def redirect_to(options = {}, response_status = {}) # for debug purposes
  ::Rails.logger.error("Redirected by #{caller(1).first rescue "unknown"}")
  super(options, response_status)
  end

  before_action :foo_function

  def foo_function  
    # sets the username display
    unless session[:user_id].nil?
      user = User.find(session[:user_id])
      @name = user.read_attribute('username')
    end
    # sets the page
    page = VimeoModel::get_page   # assumes that VimeoModel::page is more likely to be updated
    unless page.nil?
      session[:page] = page
    else
      VimeoModel::set_page session[:page]
    end
  end

  def update_session auth # save credentials (after login, refresh token)
    session[:google_access] = auth.access_token 
    session[:google_refresh] = auth.refresh_token
    session[:expires_in] = auth.expires_in
    session[:issued_at] = auth.issued_at
  end

  protected
  def check_login_state
    unless session[:user_id]
      redirect_to login_user_index_path
    end
    return false
  end

  protected
  def check_vlogin_state
    unless session[:vimeo_token]
      redirect_to vlogin_user_path
    else
      VimeoModel::set_session session[:vimeo_token], session[:vimeo_secret]
    end
    return false
  end

  protected
  def authenticate_admin # called only when user is logged in
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

  protected
  def save_login_state # skip login if already logged in, initialize google client with existing credentials
    if session[:user_id]
      GoogleClient::set_access session[:google_access], session[:google_refresh], session[:expires_in], session[:issued_at]
  		redirect_to root_url
      return true
  	else
  		return false
  	end
  end

  protected
  def save_vlogin_state # initialize vimeo client with existing credentials
    VimeoModel::set_session session[:vimeo_token], session[:vimeo_secret] if session[:vimeo_token]
    return false
  end

end
