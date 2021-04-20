# change role for user found by email
task change_role: :environment do
  print 'Enter email to change role : '
  email = $stdin.gets
  # remove newline
  email.delete! "\n"
  print 'Enter role to set : '
  role = $stdin.gets
  # remove newline
  role.delete! "\n"
  user = User.where(email: email.strip).first
  user.role = role.strip
  user.save
end
