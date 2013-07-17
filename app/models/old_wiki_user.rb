class OldWikiUser

  include Mongoid::Document
  include Mongoid::Paranoia
  #include Mongoid::Audit::Trackable

  field :email, type: String
  field :name, type: String

  validates_uniqueness_of :name

  belongs_to :user

  attr_accessible :email, :name, :user_id

end
