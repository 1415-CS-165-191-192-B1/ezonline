class Notif < ActiveRecord::Base
  belongs_to :user
  belongs_to :doc
  default_scope { order('created_at DESC') }
end