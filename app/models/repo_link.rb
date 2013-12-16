class RepoLink
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  field :repo, type: String
  field :folder, type: String, :default => '/'
  field :user, type: String
  field :name, type: String

  belongs_to :page

  def out_name
    return name if (!name.nil? and !name.empty?)
    folder_name = folder.split('/').last
    folder_name.nil? ? repo : folder_name
  end

  # for compatibility with simple form
  def user_repo
    "#{user}/#{repo}"
  end

  # for compatibility with simple form
  def page_title
    page.nil? ? '' : page.title
  end

  def full_url
    "https://github.com/#{user}/#{repo}#{folder=='/' ? '' : '/tree/master'+folder}"
  end

end
