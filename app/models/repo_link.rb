class RepoLink
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  field :repo, type: String
  field :folder, type: String, :default => '/'
  field :user, type: String

  belongs_to :page

  def namespace
    self.page ? page.namespace.pluralize.downcase : folder.split('/')[1]
  end

  # for compatibility with simple form
  def user_repo
    "#{user}/#{repo}"
  end

  # for compatibility with simple form
  def page_title
    page.nil? ? '' : page.title
  end

  def out_name
    if !page.nil?
      return page.title
    end
    folder.split('/').last
  end

  def full_url
    "https://github.com/#{user}/#{repo}#{folder=='/' ? '' : '/tree/master'+folder}"
  end

end
