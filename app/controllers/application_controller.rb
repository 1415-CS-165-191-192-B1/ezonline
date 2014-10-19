class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected
  def authenticate_user # check if user is authorized to use app
  	if session[:user_id] # session will not be saved otherwise
  		@current_user = User.find session[:user_id]
  		return true
  	else
  		redirect_to(:controller => 'user', :action => 'login')  # prompt user to login
  		return false
  	end
  end

  def save_login_state # skip login if already logged in, initialize google client with existing credentials
  	if session[:user_id] 
  		redirect_to(:controller => 'user', :action => 'list')
      GoogleClient::set_access session[:access_token], session[:refresh_token], session[:expires_in], session[:issued_at]
  		return false
  	else
  		return true
  	end
  end

end
