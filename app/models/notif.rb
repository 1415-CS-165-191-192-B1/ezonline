class Notif < ActiveRecord::Base
  belongs_to :user
  belongs_to :doc
  default_scope { order('created_at DESC') }
  validates :doc_id, presence: true, length: { maximum: 255 }
  validates :user_id, presence: true, length: { maximum: 255 }

  def self.create_new(user_id, doc_id)
    doc = Doc.find(doc_id)
    user = User.find(user_id)
    task = Task.find_by(doc_id: doc.doc_id, user_id: user.user_id)
    #task = Task.find_by doc_id: doc_id, user_id: user_id # fails bec of diff data types
    task.update_attribute(:done, true)

    notif = new(from_id: user_id, to_id: task.admin_id, doc_id: doc_id)
    return :success, "A notification was sent to the admin." if notif.save
    return :error, "Failed to send a notification to the admin."
  end

end