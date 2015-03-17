class Snippet < ActiveRecord::Base
	has_many :commits, :dependent => :delete_all
	belongs_to :docs
end