class Snippet < ActiveRecord::Base
	belongs_to :doc
	has_many :commits
end
