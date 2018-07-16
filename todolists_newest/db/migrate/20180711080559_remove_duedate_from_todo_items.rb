class RemoveDuedateFromTodoItems < ActiveRecord::Migration
  def change
    remove_column :todo_items, :duedate
  end
end
