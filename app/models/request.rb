class Request < ActiveRecord::Base
  self.primary_key = :user_id
  default_scope { order('created_at DESC') }
  validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: true }
  validates :username, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }

  def self.create_new(user_id, email, username)
  	request = new(user_id: user_id, email: email, username: username)
    return 'Sorry, you have no permission to use this application. A request was sent to grant access.' if request.save
    return 'A request was already sent to the application. Please try again later.'
  end

end
