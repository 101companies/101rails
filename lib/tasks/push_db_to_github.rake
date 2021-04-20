def get_production_db
  mongo_user = ENV['MONGODB_USER']
  mongo_password = ENV['MONGODB_PWD']
  if mongo_user.nil?
    puts "Username for production mongodb wasn't found in PATH variable".red
    return false
  elsif mongo_password.nil?
    puts "Password for production mongodb wasn't found in PATH variable".red
    return false
  else
    # remove odl dump
    puts 'Removing old dump'.yellow
    sh 'rm -rf dump/*'
    # get new dump
    puts 'Importing db'.yellow
    sh "mongodump -h db.101companies.org -u #{mongo_user} -p #{mongo_password} --db wiki_production"
    # prepare dump for import on dev machine
  end
  true
end

task push_production_db_to_github: :environment do
  # TODO: check, if repo exists?
  def_password = ENV['GMAIL_PASSWORD']
  if def_password.nil?
    puts "You don't have password for encrypting db backup!".red
  else
    get_production_db
    sh "zip -P #{def_password} -r dump_zip/full_backup.zip dump"
    sh "cd dump_zip && git add full_backup.zip && git commit -m 'Full backup, #{Time.zone.now}' && git push origin master && git gc"
  end
end

task import_production_db_to_local_dev_db: :environment do
  get_production_db
  puts 'Rename wiki_production db to wiki_development'.yellow
  sh 'mv dump/wiki_production dump/wiki_development'
  # delete old local db and import new
  puts 'Droping old development db and importing new'.yellow
  sh 'mongorestore --directoryperdb dump/wiki_development --drop'
end
