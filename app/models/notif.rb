class Notif < ActiveRecord::Base
  belongs_to :user, :foreign_key => :from_id
  belongs_to :doc
  default_scope { order('created_at DESC') }
  validates :doc_id, presence: true, length: { maximum: 255 }
  validates :from_id, presence: true, length: { maximum: 255 }
  validates :to_id, presence: true, length: { maximum: 255 }

  # Creates a new notification
  #
  # @param user_id [Decimal] The user_id of the user who sent the notification
  # @param doc_id [Decimal] The doc_id of the document which was edited and sent by the user
  # @return [Symbol, String] "A notification was sent to the admin." if the notification was sent successfully to the admin,
  # 	or "Failed to send a notification to the admin.", if the notification was not sent to the admin
  def self.create_new(user_id, doc_id)
    task = Task.find_by(doc_id: doc_id, user_id: user_id)
    #task = Task.find_by doc_id: doc_id, user_id: user_id # fails bec of diff data types
    task.update_attribute(:done, true)

    notif = new(from_id: task.user_id, to_id: task.admin_id, doc_id: task.doc_id)
    return :success, "A notification was sent to the admin." if notif.save
    return :error, "Failed to send a notification to the admin."
  end

  def self.get_all(user_id)
    notifs = Notif.where(to_id: user_id)
    notifs_with_extras = Array.new

    unless notifs.nil?
      notifs.each do |notif|
        user = User.find_by user_id: notif.from_id
        doc = Doc.find_by doc_id: notif.doc_id

        unless doc.nil? or user.nil?
          hash = {:id => notif.id, 
                  :date => notif.created_at, 
                  :username => user.username, 
                  :docname => doc.docname,
                  :responded => notif.responded}
          notifs_with_extras << hash
        end
      end
    end
    return notifs_with_extras
  end

end
