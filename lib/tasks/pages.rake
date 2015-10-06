namespace :pages do
  desc "TODO"
  task :findDuplicates => :environment do
    dups = []
    Page.each do |page|
      ds = Page.where(title: page.title, namespace: page.namespace).ne(id: page.id).to_a
      if ds.length > 0
        ds << page
      end
      dups << ds
    end
    dups = dups.reject { |l| l.empty? }
    dups.each do |duplicate|
      puts 'Duplicates:'
      ap duplicate.map { |page| page.full_title }
      puts ''
    end

  end

end
