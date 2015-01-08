require 'vimeo_client'

module VimeoModel

	ID = '265cb46f436a81f5d8a6ea991898df98b1ccb063'

	SECRET = 'd7b7f66bfd4a565fcad1b3b9c23446e2b32f8f04'

	TOKEN = 'c54317838752b29b6cd05e48b0f85480'

	URI = 'http://localhost:3000/vauthentication'

	USERNAME = 'EZOnline Development'

	@@token = nil
	@@secret = nil
	@@page_num = 1

	def self.reset_session
		@@token = nil
		@@secret = nil
		@@page_num = 1
	end

	def self.set_session t, s, p
		@@token = t
		@@secret = s
		@@page_num = p
	end

	def self.token
		@@token
	end

	def self.secret
		@@secret
	end

	def self.page
		@@page_num.to_s
	end

	def self.inc_page
		@@page_num += 1
	end

	def self.reset_page
		@@page_num = 1
	end

	def self.is_logged_in
		true unless @@token.nil? || @@secret.nil?
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
		rescue ActiveRecord::RecordNotUnique
			return
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
		while true 
			#begin
				#video = Video.find(:first, :conditions => ["lower(title) = ?", title.downcase])
			video = Video.where("lower(title) = ?", title.downcase).first
			unless video.nil?
				return video.read_attribute('video_id')	#return video_id
			#rescue ActiveRecord::RecordNotFound	#video not yet in database
			else
				unless VimeoClient::fetch_videos #fetch next set of videos
					break	#already fetched all videos
				end
			end
		end
		return nil
	end

	def self.save title, video_id
		snippet = Snippet.where("lower(title) = ?", title.downcase).first
		
		unless snippet.nil? or video_id.nil?
			snippet.update_attribute :video_id, video_id 
		else
			return nil
		end
	end
end