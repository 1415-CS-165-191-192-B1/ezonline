class Tasks < ActiveRecord::Migration
  def change
  	create_table :tasks, :id => false do |t|
  		t.string :doc_id, :null => false
  		t.decimal :user_id, :precision => 21, :null => false
  		t.boolean :done, :default => false
  		t.timestamps
  	end
  	add_index :tasks, :doc_id, :unique => true
  	execute "ALTER TABLE tasks ADD PRIMARY KEY (doc_id);" 
  end
end

