class User < ActiveRecord::Base
  self.primary_key = :user_id
  has_many :commits
  has_many :notifs, :dependent => :delete_all
  has_many :tasks, :dependent => :delete_all

  def initialize(attributes = {})
  	super
    @user_id = attributes[:user_id]
    @username = attributes[:username]
    @email = attributes[:email]
    @admin = attributes[:admin].nil? ? false : attributes[:admin]
  end
end
