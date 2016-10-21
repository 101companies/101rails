namespace :pages do

  task import_mongo: :environment do
    system "mongoexport --pretty --jsonArray --db wiki_production --collection pages --out pages.json"
    pages = JSON::parse(File.read('pages.json'))

    system "mongoexport --pretty --jsonArray --db wiki_production --collection page_changes --out page_changes.json"
    changes = JSON::parse(File.read('page_changes.json'))

    system "mongoexport --pretty --jsonArray --db wiki_production --collection users --out users.json"
    users = JSON::parse(File.read('users.json'))

    system "mongoexport --pretty --jsonArray --db wiki_production --collection repo_links --out repo_links.json"
    repo_links = JSON::parse(File.read('repo_links.json'))

    pages = rewrite_foreign_keys(pages)
    changes = rewrite_foreign_keys(changes)
    users = rewrite_foreign_keys(users)
    repo_links = rewrite_foreign_keys(repo_links)

    ActiveRecord::Base.transaction do
      page_mapping = {}
      pages.each do |page|
        begin
          ActiveRecord::Base.connection.execute("SAVEPOINT page_savepoint")
          new_page = Page.create!(
            title: page['title'],
            namespace: page['namespace'],
            raw_content: page['raw_content'],
            html_content: page['html_content'],
            used_links: page['used_links'],
            subresources: page['subresources'],
            headline: page['headline'],
            verified: page['verified'],
            created_at: page['created_at']['$date'],
            updated_at: page['updated_at']['$date']
          )
          page_mapping[page['id']] = new_page
        rescue ActiveRecord::RecordNotUnique
          ActiveRecord::Base.connection.execute("ROLLBACK TO SAVEPOINT page_savepoint")
        end
      end

      user_mapping = {}
      users.each do |user|
        if !user['github_token']
          next
        end

        if !user['github_uid']
          next
        end

        user_object = User.create!(
          email: user['email'],
          role: user['role'],
          name: user['name'],
          github_name: user['github_name'],
          github_avatar: user['github_avatar'],
          github_token: user['github_token'],
          github_uid: user['github_uid'],
          created_at: user['created_at']['$date'],
          updated_at: user['updated_at']['$date']
        )
        user_mapping[user['id']] = user_object

        if user['page_ids']
          user['page_ids'].each do |page_id|
            page_id = page_id['$oid']
            page = page_mapping[page_id]
            if page
              user_object.pages << page
            end
          end
        end
      end

      changes.each do |change|
        if !change['user_id']
          next
        end
        PageChange.create!(
          page_id: page_mapping[change['page_id']['$oid']],
          user_id: user_mapping[change['user_id']['$oid']],
          title: change['title'],
          namespace: change['namespace'],
          raw_content: change['raw_content'],
          created_at: change['created_at']['$date']
        )
      end

      repo_links.each do |repo_link|
        if !repo_link['page_id']
          next
        end
        RepoLink.create!(
          repo: repo_link['repo'],
          folder: repo_link['folder'],
          user: repo_link['user'],
          page: page_mapping[repo_link['page_id']['$oid']],
          created_at: repo_link['created_at']['$date'],
          updated_at: repo_link['updated_at']['$date']
        )
      end

    end
  end

  def rewrite_foreign_keys(collection)
    collection.map do |item|
      item['id'] = item['_id']['$oid']
      item
    end
  end

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

  desc "dump all pages as csv"
  task :csv_dump => :environment do
    CSV.open("pages.csv", "wb") do |csv|
      csv << ['Title', 'Namespace', 'Delete?']
      Page.each do |page|
        csv << [page.title, page.namespace, '']
      end
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
