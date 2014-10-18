class Commit < ActiveRecord::Base
	belongs_to :user
    belongs_to :snippet
end
