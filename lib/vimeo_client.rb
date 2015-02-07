require 'vimeo_client'

class VimeoClient

	@@base = Vimeo::Advanced::Base.new(VimeoModel::ID, VimeoModel::SECRET)

	def self.reset
		@@base = Vimeo::Advanced::Base.new(VimeoModel::ID, VimeoModel::SECRET)
	end

	def self.fetch_oauth
		request_token = @@base.get_request_token
		request_token.secret
	end

	def self.fetch_url
		@@base.authorize_url
	end

	def self.retrieve_base
		@@base = Vimeo::Advanced::Base.new(VimeoModel::ID, VimeoModel::SECRET)
	end

	def self.retrieve_video
		Vimeo::Advanced::Video.new(VimeoModel::ID, VimeoModel::SECRET, 
								   :token => VimeoModel::token, :secret => VimeoModel::secret)
	end

end
