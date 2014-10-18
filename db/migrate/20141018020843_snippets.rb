class Snippets < ActiveRecord::Migration
  def change
  	create_table :snippets do |s|
  		#s.references :files
  		s.string :title, :null => false
  		s.string :video_link, :limit => 100
  	end
  end
end
