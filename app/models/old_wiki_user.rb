class OldWikiUser

  include Mongoid::Document

  field :email, type: String
  field :name, type: String

  belongs_to :user

  attr_accessible :email, :name, :user_id

end
