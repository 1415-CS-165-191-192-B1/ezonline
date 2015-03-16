class AddRespondedToNotifs < ActiveRecord::Migration
  def change
    add_column :notifs, :responded, :boolean, :default => false
  end
end
