class User < ActiveRecord::Base
  self.primary_key = :user_id
  has_many :commits
  has_many :notifs, :dependent => :delete_all
  has_many :tasks, :dependent => :delete_all
  validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: true }
  validates :username, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }

  def self.create_new(user_id)
  	request = Request.find(user_id)
    user = new(user_id: request.user_id, username: request.username, email: request.email)
    request.destroy
    return :success, "You successfully authorized " + user.username if user.save && request.destroyed?
    return :error, "Failed to authorize " + user.username
  end

  def self.get_username(user_id)
  	find(user_id).username
  end

  def self.find_if_exists(user_id)
  	begin
  	  user = find(user_id)
  	  return user
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end

  def self.delete_and_respond(user_id)
    user = find(user_id)
    user.delete
    return :success, "You successfully unauthorized " + user.username if user.destroyed?
    return :error, "Failed to unauthorize " + user.username
  end

end
