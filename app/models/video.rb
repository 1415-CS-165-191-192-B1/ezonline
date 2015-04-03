class Video < ActiveRecord::Base
  self.primary_key = :video_id
  
  def self.create_new(snippet_title)
  	video_id = VimeoModel::find snippet_title # search by snippet title
    return :success, "Successfully added video for this snippet." if VimeoModel::save(snippet_title, video_id)
	return flash[:error] = "Failed to retrieve video for this snippet." 
  end

end