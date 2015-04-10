class Doc < ActiveRecord::Base
  self.primary_key = :doc_id
  has_many :snippets, :dependent => :destroy
  has_many :tasks, :dependent => :delete_all
  has_many :notifs, :dependent => :delete_all
  validates :docname, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: true }
  default_scope { order('created_at DESC') }

  def self.get_name(doc_id)
  	find(doc_id).docname
  end 

  def self.delete_and_respond(doc_id)
    doc = find(doc_id)
    doc.destroy
    return :success, "The file '#{doc.docname}' was successfully removed from the database." if doc.destroyed?
    return :error, "Unable to delete file '#{doc.docname}'"
  end

  def self.get_all
    docs = all
    files = Hash.new
    workers = Hash.new

    docs.each do |doc|
      id = doc.read_attribute('doc_id')
      files[doc] = doc.snippets
      task = Task.find_by doc_id: id
      user = User.find_by user_id: task.user_id unless task.nil?
      workers[id] = user.username unless user.nil?
    end
    return files, workers
  end

end