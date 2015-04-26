class User < ActiveRecord::Base
  self.primary_key = :user_id
  has_many :commits
  has_many :notifs, :dependent => :delete_all
  has_many :tasks, :dependent => :delete_all
  validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: true }
  validates :username, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }

  # Creates/Adds a new user (admin only)
  #
  # @param user_id [Decimal] id of the user to be added
  # @return [Symbol, String] "You successfully authorized " + user.username if the user was successfully authorized,
  # 	or "Failed to authorize " + user.username if the user was not authorized (due to error)
  # @note Requests are destroyed once the admin authorized the users who requested it
  def self.create_new(user_id)
  	request = Request.find(user_id)
    user = new(user_id: request.user_id, username: request.username, email: request.email)
    request.destroy
    return :success, "You successfully authorized " + user.username if user.save && request.destroyed?
    return :error, "Failed to authorize " + user.username
  end

  # Gets the user name of the user
  # @param user_id [Decimal] id of the user who we want to get the name
  # @return [void]
  def self.get_username(user_id)
  	find(user_id).username
  end

  # Tells if the user exist or not given its user_id (adnmin only)
  #
  # @param user_id [Decimal] id of the user we want to find
  # return [User] user if it exist
  # return [Null] if user does not exist
  def self.find_if_exists(user_id)
  	begin
  	  user = find(user_id)
  	  return user
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end

  # Deletes a user from the authorized users list (admin only)
  #
  # @param user_id [Decimal] id of the user we want to unauthorize
  # @return [Symbol, String] "You successfully unauthorized " + user.username if the user was successfully removed,
  # 	or "Failed to unauthorize " + user.username if the user was not removed
  def self.delete_and_respond(user_id)
    user = find(user_id)
    user.delete
    return :success, "You successfully unauthorized " + user.username if user.destroyed?
    return :error, "Failed to unauthorize " + user.username
  end

end
