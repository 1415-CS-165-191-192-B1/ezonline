class Videos < ActiveRecord::Migration
  def change
  	create_table :videos, :id => false do |v|
  		v.string :video_id, :null => false
  		v.string :title
  	end 
  	add_index :videos, :video_id, :unique => true
  	execute "ALTER TABLE videos ADD PRIMARY KEY (video_id);"
  end
end
