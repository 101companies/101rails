class OldWikiUser

  include Mongoid::Document
  include Mongoid::Paranoia
  #include Mongoid::Audit::Trackable

  field :email, type: String
  field :name, type: String

  # added index -> unique user by nick from old wiki
  index({name: 1}, {unique: true})

  belongs_to :user

  attr_accessible :email, :name, :user_id

end
