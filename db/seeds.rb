# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts 'SETTING UP DEFAULT USER LOGIN'

def create_user(name, email, password, role)

  # find user by email
  user = User.where(email: email).first

  # if doesn't exist -> create him
  if !user
    user = User.create! :name => name,
                        :email => email,
                        :password => password,
                        :password_confirmation => password,
                        :role => role
    puts 'New user created: ' << user.name
  else
    user.role = "admin"
    user.save
    puts 'Updated role to "admin" for ' << user.name
  end

end

puts 'DON\'T DO IT IN PRODUCTION!!!'
create_user('Andrei Varanovich', 'dotnetby@gmail.com', 'tester', 'admin')
create_user('Olexiy Lashyn', 'aleksey.lashin@gmail.com', 'tester', 'admin')
create_user('Arkadi Schmidt', 'arkadi.schmidt@gmail.com', 'tester', 'admin')
create_user('Ralf Lämmel', 'rlaemmel@gmail.com', 'tester', 'admin')
create_user('Thomas Schmorleiz', 'tschmorleiz@gmail.com', 'tester', 'admin')
