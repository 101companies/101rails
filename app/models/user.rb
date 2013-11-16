class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  def self.role_options
    ['admin', 'editor', 'guest', 'deprecated']
  end

  field :email,          :type => String
  field :role,           :type => String, :default => "guest"
  field :name,           :type => String

  # github data
  field :github_name,    :type => String
  field :github_avatar,  :type => String, :default => "http://www.gravatar.com/avatar"
  field :github_token,   :type => String
  field :github_uid,     :type => String

  has_many :old_wiki_users
  has_many :page_changes
  has_and_belongs_to_many :pages, :class_name => 'Page', :inverse_of => :users
  has_many :contribution_pages, :class_name => 'Page', :inverse_of => :contributor

  validates_uniqueness_of :email
  validates_uniqueness_of :github_uid

  validates_presence_of :name, :email, :github_uid, :github_token, :github_name

  attr_accessible :role, :page_ids, :old_wiki_user_ids, :contribution_page_ids

  def get_repos
    (Octokit.repositories self.github_name, {:type => 'all'}).map do |repo|
      repo.full_name
    end
  end

  def get_repo_dirs(repo, recursive = false)
    base_url = "https://api.github.com/repos/"
    last_commit = JSON.parse(HTTParty.get("#{base_url}#{repo}/commits").body).first["sha"]
    run_recursive = recursive ? "?recursive=1" : ""
    files_and_dirs = JSON.parse(HTTParty.get("#{base_url}#{repo}/git/trees/#{last_commit}#{run_recursive}").body)
    files_and_dirs["tree"].each.select{|node| node["type"] == 'tree'}.map{|node| node['path']}
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
