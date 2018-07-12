class TodoItem < ActiveRecord::Base

# Display the number of completed TodoItems on the index page.

# 1. Implement a class method in the TodoItem model that returns the count of completed TodoItems.

# 2. Update the index method in the controller class to assign the count of completed TodoItems
# in a member variable (.e.g, @number_of_completed_todos)

# 3. Display the count of completed TodoItems on the index page using
# a reference by the view – to the member variable deﬁned in the controller class.
# The grader is looking for the result to be expressed as Number of Completed Todos:
# anywhere on the page – where # is the number of completed todos.
# There must be a single space between the : and number.
  def self.count_of_completed
    self.where("completed is ?", true).count
  end
end
