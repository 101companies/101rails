namespace :pages do

  task rename_at_to101: :environment do
    Page.where(title: /^@/).each do |page|
      page.update_or_rename(page.title.sub('@', '101'), page.raw_content, [], nil)
    end
  end

  task fix_old_links: :environment do
    Page.where(raw_content: /\[\[@/).each do |page|
      page.raw_content = page.raw_content.gsub('[[@', '[[101')
      page.save!
    end
  end

  desc "TODO"
  task :findDuplicates => :environment do
    dups = []
    Page.each do |page|
      ds = Page.where(title: page.title, namespace: page.namespace).ne(id: page.id).to_a
      if ds.length > 0
        ds << page
      end
    end
    dups = dups.reject { |l| l.count == 0 }
    dups.each do |duplicate|
      puts 'Duplicates:'
      ap duplicate.map { |page| page.full_title }
      puts ''
    end
    ap dups
    dups.shift.each do |page|
      ap 'deleting:'
      ap page.full_title
      page.destroy!
    end
  end

end
