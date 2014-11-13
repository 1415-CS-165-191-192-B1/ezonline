class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def redirect_to(options = {}, response_status = {}) 
  ::Rails.logger.error("Redirected by #{caller(1).first rescue "unknown"}")
  super(options, response_status)
  end

  protected
  def check_login_state
    unless session[:user_id]
      redirect_to user_login_path
    end
    return false
  end

  protected
  def authenticate_admin
    if session[:user_id]
      @current_user = User.find session[:user_id] # no need for rescue ActiveRecord::RecordNotFound
      GoogleClient::set_access session[:google_access], session[:google_refresh], session[:expires_in], session[:issued_at]
      unless @current_user.admin
        redirect_to root_url
      end # end unless
      return true
    else
      redirect_to user_login_path
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

end
