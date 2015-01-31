module API
	class UsersController < ApplicationController
		respond_to :xml, :json

		def index
			@users = User.all
			respond_with(@users)
		end
	end
end