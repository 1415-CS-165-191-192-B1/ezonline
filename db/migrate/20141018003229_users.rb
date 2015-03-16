class Users < ActiveRecord::Migration
  def change
  	create_table :users, :id => false do |u|
  		u.decimal :user_id, :precision => 21, :null => false
  		u.string :username, :limit => 30
  		u.string :email, :limit => 30
  		u.boolean :admin, :default => false
  	end
  	add_index :users, :user_id, :unique => true
  	execute "ALTER TABLE users ADD PRIMARY KEY (user_id);"
  end
end
