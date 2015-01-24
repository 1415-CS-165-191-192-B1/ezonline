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

	def self.retrieve
		@@base = Vimeo::Advanced::Base.new(VimeoModel::ID, VimeoModel::SECRET)
	end

	def self.fetch page 	#retrieves videos in page and saves to database
		video = Vimeo::Advanced::Video.new(VimeoModel::ID, VimeoModel::SECRET, 
										   :token => VimeoModel::token, :secret => VimeoModel::secret)
		
		begin
			response = video.get_all(VimeoModel::USERNAME, { :page => page, :per_page => "50", :sort => "newest" })
			return VimeoModel::save_videos response

		rescue Vimeo::Advanced::RequestFailed 
			return false
		end
	end

end
