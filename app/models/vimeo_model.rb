module VimeoModel

	ID = '265cb46f436a81f5d8a6ea991898df98b1ccb063'

	SECRET = 'd7b7f66bfd4a565fcad1b3b9c23446e2b32f8f04'

	TOKEN = 'c54317838752b29b6cd05e48b0f85480'

	URI = 'http://localhost:3000/vauthentication'

	USERNAME = 'EZOnline Development'

	def self.reset_session
		@token = nil
		@secret = nil
	end

	def self.set_auth t, s
		@token = t
		@secret = s
	end

	def self.token
		@token
	end

	def self.secret
		@secret
	end

	def self.is_logged_in
		true unless @token.nil? || @secret.nil?
	end

	def self.save_latest	# called upon login or refresh, get latest 5 pages
		for page in 1..5
			VideoGet.perform_async page, @token, @secret
		end
	end

	def self.find title
		video = Video.where("lower(title) = ?", title.downcase).first
		unless video.nil? # video not yet in database
			return video.read_attribute('video_id')	# return video_id
		else 
			return nil
		end
	end

	def self.save title, video_id
		snippet = Snippet.where("lower(title) = ?", title.downcase).first
		
		unless snippet.nil? or video_id.nil?
			snippet.update_attribute :video_id, video_id 
			return true
		else
			return nil
		end
	end
end