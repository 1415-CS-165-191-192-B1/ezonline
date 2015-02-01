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
		
		VimeoModel::set_page Integer(page)+1 # to ensure that page is updated after every call

		begin
			response = video.get_all(VimeoModel::USERNAME, { :page => page, :per_page => "1", :sort => "newest" })
			return VimeoModel::save_videos response

		rescue Vimeo::Advanced::RequestFailed 
			VimeoModel::set_page 1
			return false	# no more videos to get
		end
	end

end
