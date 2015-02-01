class User < ActiveRecord::Base
	self.primary_key = :user_id
	
	has_many :commits
	has_many :notifs, :dependent => :delete_all
	has_many :tasks, :dependent => :delete_all
end
