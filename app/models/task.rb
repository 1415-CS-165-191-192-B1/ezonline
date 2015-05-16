# Class for the tasks assigned by the admins to the users. Contains the methods for creating and getting the tasks.
class Task < ActiveRecord::Base
  self.primary_key = :doc_id
  belongs_to :user
  belongs_to :doc
  default_scope { order('created_at DESC') }

  # Creates a new task
  #
  # @param admin_id [Decimal] id of the admin who will create the task
  # @param user_id [Decimal] id of the user to whom the task will be assigned to
  # @param doc_id [Decimal] id of the document which will be assigned
  # @return [Symbol, String] flash message and string depending on the outcome of the creation of the task
  # @note Doc can only be assigned to one user  
  def self.create_new(admin_id, user_id, doc_id)
    old_task = find_by(doc_id: doc_id)
    if user_id == 0
      if old_task
        old_task.delete
        return :success, "Successfully unassigned file." if old_task.destroyed?
        return :error, "Failed to unassign file."
      end
    else
      user = User.find(user_id)
      if old_task # doc was previously assigned
        if old_task.user_id == user.user_id
          return :notice, "File was already assigned to " + user.username
        else
          old_task.delete
        end # end if old_task user id is selected user_id
      end # end if old_task is not nil

      # create new task
      task = new(admin_id: admin_id, user_id: user_id, doc_id: doc_id)
      return :success, "Successfully assigned file to " + user.username if task.save
      return :error, "Failed to assign file to " + user.username
    end # end if user_id is 0
  end

  # Gets all the assigned task to a user
  #
  # @param user_id [Decimal] id of the user which we want to get all assigned task
  # @return [Hash, Hash] files - the doc snippets, details - the details of the doc
  def self.get_all(user_id)
    tasks = where(user_id: user_id) # this causes an error, dk why
    files = Hash.new # hash of doc => snippets
    details = Hash.new

    unless tasks.nil?
      tasks.each do |task|
        doc = Doc.find(task.doc_id)
        files[doc] = doc.snippets
        details[doc.doc_id] = {:done => task.done, :note => task.note}
      end
      return files, details
    end
  end

end
