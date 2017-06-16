class RepoLink < ActiveRecord::Base
  belongs_to :page

  def namespace
    if self.page
      page.namespace.pluralize.downcase
    elsif folder
      folder.split('/')[1]
    else
      ''
    end
  end

  # for compatibility with simple form
  def user_repo
    "#{repo}"
  end

  # for compatibility with simple form
  def page_title
    page.nil? ? '' : page.title
  end

  def out_name
    if !page.nil?
      return page.title
    end
    unless folder.nil?
      folder.split('/').last
    else
      ''
    end
  end

  def full_url
    if repo && user && repo.include?(user)
      _, normalized_repo = repo.split('/', 2)
    else
      normalized_repo = repo
    end
    "https://github.com/#{user}/#{repo}#{folder=='/' ? '' : '/tree/master'+folder}"
  end

end
