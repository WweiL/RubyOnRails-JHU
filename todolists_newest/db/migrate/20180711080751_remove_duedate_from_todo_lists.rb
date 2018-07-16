class RemoveDuedateFromTodoLists < ActiveRecord::Migration
  def change
    remove_column :todo_lists, :due_date
  end
end
