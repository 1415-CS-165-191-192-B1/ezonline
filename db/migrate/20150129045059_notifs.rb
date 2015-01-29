class Notifs < ActiveRecord::Migration
  def change
  	create_table :notifs do |n|
  		n.decimal :from_id, :precision => 21, :null => false
  		n.decimal :to_id, :precision => 21, :null => false
  		n.string :doc_id, :null => false
  		n.timestamps
  	end
  end
end
