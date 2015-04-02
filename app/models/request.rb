class Request < ActiveRecord::Base
  self.primary_key = :user_id
  default_scope { order('created_at DESC') }

  def initialize(attributes = {})
  	super
    @user_id = attributes[:user_id]
    @email = attributes[:email]
    @username = attributes[:username]
  end
end
