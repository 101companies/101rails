task :write_wiki_content_to_file_system => :environment do
  Page.all.each do |page|
    File.open("dump_pages/#{page.namespace}:#{page.title}", 'w') do |file|
      file.write(page.raw_content)
    end
  end
end
