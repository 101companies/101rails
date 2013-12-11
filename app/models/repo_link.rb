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
    folder.split('/').last
  end

  def full_url
    "https://github.com/#{user}/#{repo}#{folder=='/' ? '' : '/tree/master'+folder}"
  end

end
