class Commit < ActiveRecord::Base
  belongs_to :user
  belongs_to :snippet
  validates :commit_text, presence: true, allow_blank: false, length: {minimum: 100},  uniqueness: { case_sensitive: false }
  default_scope { order('created_at DESC') }

  def self.create_new(user_id, snippet_id, commit_text)
  	commit = new(user_id: user_id, snippet_id: snippet_id, commit_text: commit_text)
  	return false, :notice, "Your commit was empty/too short." if commit.invalid?
  	commit.save
    return true, :success, "Update saved."    
  end

end
