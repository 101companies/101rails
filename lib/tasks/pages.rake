namespace :pages do
  desc "TODO"
  task :findDuplicates => :environment do
    Page.each do |page|
      puts Page.where(title: page).ne(namespace: page.namespace)
    end
  end

end
