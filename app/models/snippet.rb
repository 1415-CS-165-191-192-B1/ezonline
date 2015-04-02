class Snippet < ActiveRecord::Base
  has_many :commits, :dependent => :delete_all
  belongs_to :docs

  def initialize(attributes = {})
  	super
  	@doc_id = attributes[:doc_id]
  	@title = attributes[:title]
  end

end