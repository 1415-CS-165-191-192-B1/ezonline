# Class for getting the Vimeo video file
class VideoGet
  include Sidekiq::Worker

  # Performs get video
  #
  # @param token
  # @param secret
  # @return [void]
  def perform token, secret
    catch(:done) do
      for page in 1...10
        video = Vimeo::Advanced::Video.new(ENV["vimeo_id"], ENV["vimeo_secret"], :token => token, :secret => secret)
        response = video.get_all(ENV["vimeo_username"], { :page => "#{page}", :per_page => "10", :sort => "newest" })
        videos = response['videos']['video']
   
        videos.each do |v|
         throw :done if !Video.create_new(v['id'], v['title'])
        end
      end
    end
  end

end
