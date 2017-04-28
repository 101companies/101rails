class User < ActiveRecord::Base

  def self.role_options
    ['admin', 'editor', 'guest']
  end

  has_many :old_wiki_users
  has_many :page_changes
  has_and_belongs_to_many :pages

  validates_uniqueness_of :email
  validates_uniqueness_of :github_uid

  validates_presence_of :name, :email, :github_uid, :github_token, :github_name

  def get_repos
    # using oauth token to increase limit of request to github api to 5000
    client = Octokit::Client.new #access_token: self.github_token
    client.repositories(self.github_name, type: 'all', per_page: 100).map do |repo|
      repo.full_name
    end
  end

  def get_repo_dirs(repo, recursive = false)
    base_url = "https://api.github.com/repos/"
    # using oauth token to increase limit of request to github api to 5000
    uri = URI("#{base_url}#{repo}/commits")
    req = Net::HTTP::Get.new(uri)
    req['User-Agent'] = '101wiki'

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) {|http|
      http.request(req)
    }
    response_data = res.body
    last_commit = JSON.parse(response_data).first['sha']

    run_recursive = recursive ? "&recursive=1" : ""
    # using oauth token to increase limit of request to github api to 5000
    url = URI("#{base_url}#{repo}/git/trees/#{last_commit}?#{run_recursive}")
    req = Net::HTTP::Get.new(url)
    req['User-Agent'] = '101wiki'

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) {|http|
      http.request(req)
    }

    files_and_dirs = JSON.parse(res.body)
    repos = files_and_dirs["tree"].each.select{|node| node["type"] == 'tree'}.map{|node| '/' + node['path']}
    repos.prepend '/'
  end

  def get_repo_dirs_recursive(repo)
    self.get_repo_dirs(repo, true)
  end

  def populate_data(omniauth)
    self.email = omniauth['info']['email']
    self.name = omniauth['info']['name']
    self.github_name = omniauth['info']['nickname']
    self.github_avatar = omniauth['info']['image']
    self.github_token = omniauth['credentials']['token']
    self.github_uid = omniauth['uid']
  end

end
