class Task < ActiveRecord::Base
  self.primary_key = :doc_id
  belongs_to :user
  belongs_to :doc
  validates_uniqueness_of :doc_id
  default_scope { order('created_at DESC') }

  def initialize(attributes = {})
    super
    @admin_id = attributes[:admin_id]
    @user_id = attributes[:user_id]
    @doc_id = attributes[:doc_id]
  end
end