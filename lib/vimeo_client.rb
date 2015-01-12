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

	def self.fetch_videos
		video = Vimeo::Advanced::Video.new(VimeoModel::ID, VimeoModel::SECRET, 
										   :token => VimeoModel::token, :secret => VimeoModel::secret)
		
		begin
			response = video.get_all(VimeoModel::USERNAME, { :page => VimeoModel::page, :per_page => "1", :sort => "newest" })
			VimeoModel::inc_page
			VimeoModel::save_videos response
			return true
		#if response.nil? || response['err'] && response['err']['code'] == '50' #exceeded page number
		rescue Vimeo::Advanced::RequestFailed 
			VimeoModel::reset_page
			return false
		end
	end

end
