# change role for user found by email
task :get_db do
  mongo_user = ENV["MONGODB_USER"]
  mongo_password = ENV["MONGODB_PWD"]
  if mongo_user.nil?
    puts "Username for production mongodb wasn't found in PATH variable".red
  else
    if mongo_password.nil?
      puts "Password for production mongodb wasn't found in PATH variable".red
    else
      # remove odl dump
      puts "Removing old dump".yellow
      sh "rm -rf dump"
      # get new dump
      puts "Importing db".yellow
      sh "mongodump -h db.101companies.org -u #{mongo_user} -p #{mongo_password}"
      # prepare dump for import on dev machine
      puts "Rename wiki_produciton db to wiki_development".yellow
      sh "mv dump/wiki_production dump/wiki_development"
      # delete old local db and import new
      puts "Droping old development db and importing new".yellow
      sh "mongorestore --directoryperdb dump/wiki_development --drop"
    end
  end
end
