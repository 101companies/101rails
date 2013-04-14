# change role for user found by email
task :change_role => :environment do
  print 'Enter email to change role : '
  email = STDIN.gets
  # remove newline
  email.delete! "\n"
  print 'Enter role to set : '
  role = STDIN.gets
  # remove newline
  role.delete! "\n"
  user = User.where(:email => email).first
  user.role=role
  user.save
end
