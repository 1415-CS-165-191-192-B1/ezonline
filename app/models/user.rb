class User < ActiveRecord::Base
	self.primary_key = :user_id
	has_many :commits
end
