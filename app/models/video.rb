class Video < ActiveRecord::Base
  self.primary_key = :video_id
  validates :title, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }
  
  def self.create_new(id, title)
    video = new(title: title, video_id: id)
    return true if video.save
    return false
  end

  def self.get_video_id video_title
  	video = where("lower(title) = ?", video_title.downcase).first
    return video.video_id unless video.nil? # video not yet in database
    return nil
  end

end