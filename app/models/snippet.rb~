# Class for the snippets. Contains the methods updating the video ids for the snippets
class Snippet < ActiveRecord::Base
  has_many :commits, :dependent => :delete_all
  belongs_to :docs

  # Adds/Updates the video for a certain snippet
  #
  # @param title [String] The title of the video and the snippet
  # @return [Symbol, String] "Successfully added video for this snippet." if the video was sucessfully added to the snippet,
  # 	or "Failed to add video for this snippet." If the video was not added to the snippet
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

  # Adds/Updates all the videos for all the snippets of a certain document
  #
  # @param doc_id [Decimal] The document id of the document which we want all videos
  # 	of the snippets to be fetched
  # @return [Symbol, String] "Successfully added all videos for this file." if all the videos for the snippets were added,
  # 	or "Failed to add any video for this file." if none of the videos for the snippets were added,
  # 	or "Some videos were not found for this file." if not all videos for the snippets were added
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
