class Request < ActiveRecord::Base
	self.primary_key = :user_id
    default_scope { order('created_at DESC') }
end
