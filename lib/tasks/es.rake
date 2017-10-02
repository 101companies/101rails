namespace :es do
  desc "TODO"
  task start: :environment do
    `docker run -p 9200:9200 -p 9300:9300 elasticsearch`
  end
end
