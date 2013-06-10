task :migrate_pages => :environment do

  require 'csv'
  csv_text = File.read('page.csv')
  csv = CSV.parse(csv_text, :headers => true)

  # allowed namespaces
  namespaces = ['Concept', '101', 'Contribution', 'Contributor', 'Course', 'Dotnet',
                'Feature', 'Information', 'Issue', 'Java', 'Language',
                'Module', 'Namespace', 'Prefix', 'Resource', 'Script',
                'Service', 'Technology', 'Theme',  'Vocabulary']

  pages = []
  csv.each do |row|

    is_redirect = row.to_hash['page_is_redirect']

    # if page is redirect -> go further?
    if is_redirect == '1'
      next
    end

    title = row.to_hash['page_title']

    namespace = title.scan(/(.+)\:/)
    namespace =  namespace.to_s.strip.delete('[":]')

    if namespace == ""
      if title[0]=="@"
        namespace = "101"
      else
        namespace = "Concept"
      end
    end

    if namespaces.include? (namespace)
      title.slice!(namespace+':')
      pages << namespace + ':' + title
    end
  end

  puts '#############'
  puts 'Found pages :'
  puts pages.sort!.uniq!.count

  puts '#############'
  puts 'Removing all pages ...'
  Page.delete_all

  time_begin = Time.now

  puts '#############'
  puts 'Started populating pages at ' + time_begin.to_s

  counter = 0

  pages.each do |page|
    Page.find_or_create_page page
    counter = counter + 1
    puts "#{Page.all.count} / #{pages.count} pages created, last page : " + page
  end


  time_end = Time.now

  puts '#############'
  puts 'Ended populating pages at ' + time_end.to_s

  puts '#############'
  puts 'Spent time ' + (time_end - time_begin).to_s

  puts '#############'
  puts 'Created pages :'
  puts Page.all.count
  puts pages.count

end
