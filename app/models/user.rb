class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Audit::Trackable
  include Mongoid::Paranoia

  track_history :on => [:email, :role, :github_avatar, :github_name, :github_token, :old_wiki_user_ids,
                        :contribution_ids, :name, :page_ids]

  def self.role_options
    ['admin', 'editor', 'guest', 'nobody']
  end

  field :email,          :type => String
  field :role,           :type => String, :default => "guest"
  field :name,           :type => String

  # github data
  field :github_name,    :type => String
  field :github_avatar,  :type => String
  field :github_token,   :type => String
  field :github_uid,     :type => String

  has_many :old_wiki_users
  has_many :contributions
  has_and_belongs_to_many :pages

  validates_uniqueness_of :email
  validates_uniqueness_of :github_uid

  validates_presence_of :name, :email, :github_uid, :github_token, :github_name

  attr_accessible :role, :contributions, :page_ids, :old_wiki_user_ids

end
