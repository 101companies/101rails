# change role for user found by email
task :propagate_page_changes_to_github => :environment do
  #PageChange.where(:propagation_status => 'Not propagated').order_by(:created_at.desc).no_timeout.each do |page_change|
    #File.open("dump_pages/101wiki/#{page_change.new_namespace}:#{page_change.new_title}", 'w') do |file|
      #file.write(page_change.new_raw_content)
      #git add . && git commit -m "New content" --author="softlang@uni-koblenz.de"
    #end
  #end
  #sh "cd dump_pages && git add . && git commit -m ''"
end
