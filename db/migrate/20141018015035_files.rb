class Files < ActiveRecord::Migration
  def change
  	create_table :files, :id => false do |f|
  		f.decimal :file_id, :precision => 21, :null => false
  		f.string :filename, :limit => 50
  	end
  	execute "ALTER TABLE files ADD PRIMARY KEY (file_id);" 
  end
end
