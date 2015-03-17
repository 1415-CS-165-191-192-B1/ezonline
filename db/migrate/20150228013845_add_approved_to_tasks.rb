class AddApprovedToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :approved, :boolean, :default => false
  end
end
