class AddDueDateToTodoItems < ActiveRecord::Migration
  def change
    add_column :todo_items, :due_date, :date
  end
end
