class Docs < ActiveRecord::Migration
  def change
  	create_table :docs, :id => false do |d|
  		d.string :doc_id, :null => false
  		d.string :docname
  		d.string :link
  		d.timestamps
  	end
  	add_index :docs, :doc_id, :unique => true
  	execute "ALTER TABLE docs ADD PRIMARY KEY (doc_id);" 
  end
end
