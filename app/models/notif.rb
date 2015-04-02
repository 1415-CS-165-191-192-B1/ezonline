class Notif < ActiveRecord::Base
  belongs_to :user
  belongs_to :doc
  default_scope { order('created_at DESC') }

  def initialize(attributes = {})
  	super
    @from_id = attributes[:from_id]
    @to_id = attributes[:to_id]
    @doc_id = attributes[:doc_id]
  end
end