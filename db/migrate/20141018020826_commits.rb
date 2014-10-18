class Commits < ActiveRecord::Migration
  def change
  	create_table :commits do |c|
  		#c.references :users
  		#c.references :snippets
  		c.text :commit_text
  		c.timestamps
  	end
  end
end
