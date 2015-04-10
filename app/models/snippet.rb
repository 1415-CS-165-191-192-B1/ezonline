class Snippet < ActiveRecord::Base
  has_many :commits, :dependent => :delete_all
  belongs_to :docs

  def self.update_video_id(title)
  	snippet = where("lower(title) = ?", title.downcase).first
    #snippet = find(snippet_id)
    video_id = Video.get_video_id(snippet.title)

    unless video_id.nil?
      snippet.update_attribute :video_id, Video.get_video_id(snippet.title)
      return :success, "Successfully added video for this snippet."
    end
    return :error, "Failed to add video for this snippet."
  end

  def self.update_video_ids(doc_id)
    snippets = where(doc_id: doc_id)
    successes = 0
    snippets.each do |snippet|
      type, message = update_video_id(snippet.title)
      successes += 1 if type == :success
    end

    case successes
    when snippets.size
      return :success, "Successfully added all videos for this file."
    when 0
      return :error, "Failed to add any video for this file."
    when 1..snippets.size
      return :notice, "Some videos were not found for this file."
    end
  end

end