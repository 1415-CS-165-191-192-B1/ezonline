class Snippet < ActiveRecord::Base
	belongs_to :file
	has_many :commits
end
