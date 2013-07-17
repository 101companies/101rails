class OldWikiUser

  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Audit::Trackable

  field :email, type: String
  field :name, type: String

  validates_uniqueness_of :name

  belongs_to :user

  track_history :on => [:email, :name, :user], :track_create => true, :track_destroy => true

  attr_accessible :email, :name, :user_id

end
