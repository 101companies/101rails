class RepoLink
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  field :repo, type: String
  field :folder, type: String
  field :user, type: String
  field :url, type: String

  belongs_to :page
end
