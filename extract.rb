# encoding: UTF-8

require 'json'

def get_folders(folder, repo)
  folder = "../git_repos/#{repo}/#{folder}"
  Dir.entries(folder).select do |entry|
    File.directory? (folder + "/" + entry) and !(entry =='.' || entry == '..' || entry =='.git' || entry == '.metadata')
  end
end

def write_to_file(filename, data)
  pretty_data = pretty_out(data)
  a = File.new(filename, "w")
  a.write pretty_data
  a.close
end

def pretty_out(data)
  data = Hash[data.sort_by { |hash| hash[0] }]
  JSON.pretty_generate(data)
end

def prepare_pull_data(folder, repo, user, recursive, r_alias="")
  dirs = get_folders folder, repo if recursive

  if (repo == 'kevin-101repo') or (repo == 'ydupont-101repo')
    repo = '101repo'
  end

  pullRepoJson = Hash.new
  if recursive
    dirs.each do |dir|
     pullRepoJson[dir] = "https://github.com/#{user}/#{repo}/tree/master/#{folder}#{folder.empty? ? '' : '/'}#{dir}"
    end
  else
    if folder == ""
      folder=r_alias if r_alias!=""
      pullRepoJson[folder] = "https://github.com/#{user}/#{repo}"
    else
      folder=r_alias if r_alias!=""
      pullRepoJson[folder] = "https://github.com/#{user}/#{repo}/tree/master/#{folder}"
    end
  end
  pullRepoJson
end

def create_data(filter_pages=false)

  data = Hash.new
  data = data.merge prepare_pull_data('contributions', '101repo', '101companies', true)

  # TODO: normal names
  data = data.merge prepare_pull_data('contributions', 'ydupont-101repo', 'ydupont', true)
  data = data.merge prepare_pull_data('contributions', 'kevin-101repo', 'kevin-klein', true)

  data = data.merge prepare_pull_data('contributions', '101haskellclones', 'tschmorleiz', true)
  data = data.merge prepare_pull_data('hackathon/callref-rascal', 'SoTeSoLa', 'SoTeSoLa', false, "callref-rascal")
  data = data.merge prepare_pull_data('contributions', '101haskell', '101companies', true)
  data = data.merge prepare_pull_data('contributions', '101simplejava', '101companies', true)
  data = data.merge prepare_pull_data('', '101datalog', '101companies', true)
  data = data.merge prepare_pull_data('', '101companies-grails', 'spgroup', false, 'grails')
  data = data.merge prepare_pull_data('', 'hbase101companies', 'DerDackel', false, 'hbase')
  data = data.merge prepare_pull_data('', 'riak101companies', 'DerDackel', false, 'riak')
  data = data.merge prepare_pull_data('', 'gremlin-neo4j101companies', 'DerDackel', false, 'gremlin-neo4j')
  data = data.merge prepare_pull_data('', 'mongo101companies', 'DerDackel', false, 'mongodb')
  data = data.merge prepare_pull_data('', 'yapg', 'rlaemmel', false, 'yapg')
  data = data.merge prepare_pull_data('', '101android', 'hakanaksu', true)
  data = data.merge prepare_pull_data('', 'contributions', 'MightyNoob', true)

  # TODO: sens?
  #data = data.merge prepare_pull_data('technologies', '101repo', '101companies', true)
  #data = data.merge prepare_pull_data('languages', '101repo', '101companies', true)
  #data = data.merge prepare_pull_data('features', '101repo', '101companies', true)

  data = data.merge prepare_pull_data('services', '101worker', '101companies', true)
  data = data.merge prepare_pull_data('modules', '101worker', '101companies', true)

  if filter_pages
    # concepts
    data = data.merge prepare_pull_data('concepts', '101repo', '101companies', true)

    RepoLink.delete_all

    migration = []
    data.each do |k,v|

      pages = Page.where(:title => k)

      if (pages.count > 1)
        real_namespace = v.split('/')[8]
        pages = Page.where(:title => k, :namespace => real_namespace.singularize.capitalize)
        puts '############# ' + real_namespace.singularize.capitalize
      end

      repo = v[19 .. -1].split('/')
      a = RepoLink.new
      a.user = repo[0]
      a.repo = repo[1]
      a.folder = v.split('/')[8]
      a.url = v

      if pages and pages.count!=0
        page = pages.first
        page.repo_link = a
        #a.page = page
        #page.save
      end
      #a.save
      migration << a
      puts "#{a.user} #{a.repo} #{a.folder}  #{a.url} " ##{a.page.nil? ? a.page.title : '---'}
    end

  end


  #old_json = JSON.parse(File.read 'old.json')
  #puts "---------------------------------------"
  #puts old_json.to_a - data.to_a
  #puts "---------------------------------------"
  #puts data.to_a - old_json.to_a

  write_to_file 'new.json', data

end

create_data true
