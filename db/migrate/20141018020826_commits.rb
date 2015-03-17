class Commits < ActiveRecord::Migration
  def change
  	create_table :commits do |c|
  		c.decimal :user_id, :precision => 21, :null => false
  		c.integer :snippet_id, :null => false
  		c.text :commit_text
  		c.timestamps
  	end
  end
end
