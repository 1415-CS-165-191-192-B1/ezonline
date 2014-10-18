class File < ActiveRecord::Base
	self.primary_key = :file_id
	has_many :snippets
end
