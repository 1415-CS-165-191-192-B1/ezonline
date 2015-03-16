class Commit < ActiveRecord::Base
	belongs_to :user
    belongs_to :snippet
    validates :commit_text, presence: true, allow_blank: false, length: {minimum: 100}
    default_scope { order('created_at DESC') }
end
