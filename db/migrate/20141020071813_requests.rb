class Requests < ActiveRecord::Migration
  def change
    create_table :requests, :id => false do |r|
      r.decimal :user_id, :precision => 21, :null => false
      r.string :username, :limit => 30
      r.string :email, :limit => 30
      r.boolean :granted
      r.timestamps
    end
    add_index :requests, :user_id, :unique => true
    execute "ALTER TABLE requests ADD PRIMARY KEY (user_id);"
  end
end
