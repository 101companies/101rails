require 'string_extensions'
include StringExtensions

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  #include Mongoid::Audit::Trackable
  include Mongoid::Paranoia

  def self.role_options
    ['admin', 'editor', 'guest', 'banned', 'nobody']
  end

  field :email,              :type => String, :default => ""

  # work with roles
  field :role,               :type => String, :default => "guest"

  # github data
  field :github_name,        :type => String, :default => ''
  field :github_avatar,      :type => String, :default => ''
  field :github_token,       :type => String, :default => ''

  #mapping with old wiki
  has_many :old_wiki_users

  # creating dropdown select with roles for user model in edit view (create view)

  # run 'rake db:mongoid:create_indexes' to create indexes
  index({ email: 1 }, { unique: true, background: true })
  field :name, :type => String
  validates_presence_of :name
  attr_accessible :name, :email, :role, :created_at, :updated_at,
                  :contributions, :github_name, :page_ids, :old_wiki_user_ids

  has_many :authentications, :dependent => :delete

  has_many :contributions
  has_and_belongs_to_many :pages

  # Authentications
  after_create :save_new_authentication

   # fetch attributes from the omniauth-record.
  def apply_omniauth(omniauth)
    self.email = omniauth['info']['email'] if email.blank?
    apply_trusted_services(omniauth) if self.new_record?
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

private
  def apply_trusted_services(omniauth)
    # Merge user_info && extra.user_info
    user_info = omniauth['info']
    if omniauth['extra'] && omniauth['extra']['user_hash']
      user_info.merge!(omniauth['extra']['user_hash'])
    end

    # try name or nickname
    if self.name.blank?
      self.name   = user_info['name']   unless user_info['name'].blank?
      self.name ||= user_info['nickname'] unless user_info['nickname'].blank?
      self.name ||= (user_info['first_name']+" "+user_info['last_name']) unless user_info['first_name'].blank? || user_info['last_name'].blank?
    end

    if self.email.blank?
      self.email = user_info['email'] unless user_info['email'].blank?
    end

    # Build a new Authentication and remember until :after_create -> save_new_authentication
    @new_auth = authentications.build( :uid => omniauth['uid'], :provider => omniauth['provider'])
  end

  # Called :after_create
  def save_new_authentication
    @new_auth.save unless @new_auth.nil?
  end
end
