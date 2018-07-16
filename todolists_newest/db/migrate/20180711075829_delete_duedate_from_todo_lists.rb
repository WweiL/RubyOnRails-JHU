class DeleteDuedateFromTodoLists < ActiveRecord::Migration
  def change
    remove_column :todo_lists, :duedate
  end
end
