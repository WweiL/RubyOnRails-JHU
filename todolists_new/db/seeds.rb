require 'date'
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.destroy_all
Profile.destroy_all

users = [
  { first_name: "Carly", last_name: "Fiorina", birth_year: 1954, password: "aaa", gender: "female" },
  { first_name: "Donald", last_name: "Trump", birth_year: 1946, password: "bbb", gender: "male" },
  { first_name: "Ben", last_name: "Carson", birth_year: 1951, password: "ccc", gender: "male" },
  { first_name: "Hillary", last_name: "Clinton", birth_year: 1947, password: "ddd", gender: "female" }
]

users.each do |user|
  u = User.create! username: user[:last_name], password_digest: user[:password]
  u.create_profile! first_name: user[:first_name], last_name: user[:last_name], birth_year: user[:birth_year], gender: user[:gender]
  list = u.todo_lists.create! list_due_date: Date.today.next_year
  5.times do |n|
      list.todo_items.create! due_date: Date.today.next_year, title: "aaa#{n}", description: "Zeldaaaaa! #{n}"
  end
end
