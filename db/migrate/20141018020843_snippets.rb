class Snippets < ActiveRecord::Migration
  def change
  	create_table :snippets do |s|
  		s.string :doc_id, :null => false
  		s.string :title
  		s.string :video_link
  	end
  end
end
