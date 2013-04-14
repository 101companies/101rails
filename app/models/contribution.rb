class Contribution

  include Mongoid::Document
  include Mongoid::Timestamps

  field :url, type: String

  field :created_at, type: DateTime
  field :updated_at, type: DateTime

  belongs_to :user

  attr_accessible :user, :url, :created_at, :updated_at # wiki-page

end
