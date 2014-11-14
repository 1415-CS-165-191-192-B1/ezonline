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

	def self.fetch_videos token, secret
		video = Vimeo::Advanced::Video.new(VimeoModel::ID, VimeoModel::SECRET, :token => token, :secret => secret)
		response = video.get_all(VimeoModel::USERNAME, { :page => "1", :per_page => "25", :sort => "newest" })
		#response = video.get_by_tag("how to download memtest plus 7", { :page => "1", :per_page => "25", :full_response => true, :sort => "relevant" })
		videos = response['videos']['video']
		id = videos[0]['id']
		#video.search("how to download memtest plus 7", 
					#{ :page => "1", :per_page => "25", :full_response => "0", :sort => "newest", :user_id => nil })
	end

end
