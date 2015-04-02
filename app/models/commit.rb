class Commit < ActiveRecord::Base
  belongs_to :user
  belongs_to :snippet
  validates :commit_text, presence: true, allow_blank: false, length: {minimum: 100},  uniqueness: { case_sensitive: false }
  default_scope { order('created_at DESC') }
  attr_accessor :commit_text

  def initialize(attributes = {})
  	super
    @user_id = attributes[:user_id]
    @snippet_id = attributes[:snippet_id]
  end

end
