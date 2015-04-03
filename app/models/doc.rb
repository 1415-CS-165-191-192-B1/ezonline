class Doc < ActiveRecord::Base
  self.primary_key = :doc_id
  has_many :snippets, :dependent => :destroy
  has_many :tasks, :dependent => :delete_all
  has_many :notifs, :dependent => :delete_all
  validates :docname, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: true }
  default_scope { order('created_at DESC') }

  def self.get_name(doc_id)
  	doc = find_by(doc_id: doc_id)
  	return doc.docname
  end 

end
