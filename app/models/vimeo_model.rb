require 'vimeo_client'

module VimeoModel

	ID = '265cb46f436a81f5d8a6ea991898df98b1ccb063'

	SECRET = 'd7b7f66bfd4a565fcad1b3b9c23446e2b32f8f04'

	TOKEN = 'c54317838752b29b6cd05e48b0f85480'

	URI = 'http://localhost:3000/vauthentication'

	USERNAME = 'EZOnline Development'

	@@token = nil
	@@secret = nil
	@@page = 1

	def self.reset_session
		@@token = nil
		@@secret = nil
		@@page = 1
	end

	def self.set_session t, s
		@@token = t
		@@secret = s
	end

	def self.token
		@@token
	end

	def self.secret
		@@secret
	end

	def self.set_page page # sets the page to session[:page]
		@@page = page.nil? ? 1 : page 
	end

	def self.get_page 	# sets the session[:page]
		@@page
	end

	def self.is_logged_in
		true unless @@token.nil? || @@secret.nil?
	end

	def self.save_latest	# called upon login, get latest 250 videos
		for i in 1..5
			@@page = i
			break unless VimeoClient::fetch @@page.to_s
		end
	end

	def self.save_videos response
		videos = response['videos']['video']
		#SAVE USING ARRAY
		#video_list = []
		#videos.each do |v|
		#	hash = {id: v['id'], title: v['title']}
		#	video_list.push(hash)
		#end
		begin 
			videos.each do |v|
				video = Video.new
				video.video_id = v['id']
				video.title = v['title']
				video.save!
			end
			return true
		rescue ActiveRecord::RecordNotUnique	# database already updated
			# what if only the last video in the list is not unique?
			return false
		end
	end

	def self.find title
		# SEARCH USING ARRAY
		#unless videos.nil?
		#	video = videos.find {|v| v[:title].casecmp(title).zero? }
		#	unless video.nil? 
		#		snippet = Snippet.where(title: "#{video[:title]}")
		#    	snippet.update_attribute(:video_id, "#{video[:id]}")
		#	end
		#end

		begin
			video = Video.where("lower(title) = ?", title.downcase).first
			unless video.nil? #video not yet in database
				return video.read_attribute('video_id')	#return video_id
			else
				@@page += 1
				if VimeoClient::fetch @@page.to_s # fetched next set of videos
					raise
				else
					return nil	# already fetched all videos
				end
			end
		rescue
			retry
		end

		# retry one last time in case save_videos returned false
		video = Video.where("lower(title) = ?", title.downcase).first
		return video.read_attribute('video_id')	unless video.nil?
		
		return nil
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