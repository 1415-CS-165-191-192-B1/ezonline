class Doc < ActiveRecord::Base
	self.primary_key = :doc_id
	
	has_many :snippets, :dependent => :destroy
	has_many :tasks, :dependent => :delete_all
	has_many :notifs, :dependent => :delete_all

	validates_uniqueness_of :docname
	default_scope { order('created_at DESC') }
end
