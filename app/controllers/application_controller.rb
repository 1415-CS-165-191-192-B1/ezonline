class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected
  def authenticate_admin
    if session[:user_id]
      @current_user = User.find session[:user_id] # no need for rescue ActiveRecord::RecordNotFound
      GoogleClient::set_access session[:access_token], session[:refresh_token], session[:expires_in], session[:issued_at]
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
      GoogleClient::set_access session[:access_token], session[:refresh_token], session[:expires_in], session[:issued_at]
  		redirect_to root_url
      return true
  	else
  		return false
  	end
  end

end
