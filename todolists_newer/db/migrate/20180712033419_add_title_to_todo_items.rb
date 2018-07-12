class AddTitleToTodoItems < ActiveRecord::Migration
  def change
    add_column :todo_items, :title, :string
  end
end
