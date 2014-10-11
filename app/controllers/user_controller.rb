class UserController < ApplicationController
	def start
		user = User.new
		user.username = 'Christiane Yee'
		user.email = 'christiane.yee@gmail.com'
		user.admin = 1

		user.save
	end

	def list
		@users = User.all
	end
	helper_method :show
end
