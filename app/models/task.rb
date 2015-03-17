class Task < ActiveRecord::Base
	self.primary_key = :doc_id

	belongs_to :user
	belongs_to :doc

	default_scope { order('created_at DESC') }
end