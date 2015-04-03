class Task < ActiveRecord::Base
  self.primary_key = :doc_id
  belongs_to :user
  belongs_to :doc
  default_scope { order('created_at DESC') }

  def self.create_new(user_id, doc_id)
    old_task = find_by(doc_id: doc_id)  # doc can only be assigned to one user
    
    if user_id == 0
      old_task.delete if old_task
      return :success, "Successfully unassigned file."

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
      task = new(admin_id: user_id, user_id: user.user_id, doc_id: doc_id)
      return :success, "Successfully assigned file to " + user.username

    end # end if user_id is 0
  end
end