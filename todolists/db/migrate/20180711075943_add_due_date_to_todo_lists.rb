class AddDueDateToTodoLists < ActiveRecord::Migration
  def change
    add_column :todo_lists, :due_date, :date
  end
end
