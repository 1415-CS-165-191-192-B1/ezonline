class VimeoClient

	def self.fetch_oauth
		@base = Vimeo::Advanced::Base.new(VimeoModel::ID, VimeoModel::SECRET)
		request_token = @base.get_request_token
		request_token.secret
	end

	def self.fetch_url
		@base.authorize_url
	end

	def self.get_base
		@base = Vimeo::Advanced::Base.new(VimeoModel::ID, VimeoModel::SECRET)
	end

end
